# == Class: httpd
#
# This sets up a simple Apache HTTPD server
#
# === Parameters
#
#
# [*replace*]
#   If this is set to true we replace all config files with puppet,
#   otherwise we just insure the file is in place
#
# [*packages*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# [*config_dir*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# [*myuser*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
#
# === Examples
#
#  class { 'template':
#    packages => 'apache-uib'
#  }
#
# === Authors
#
# Raymond Kristiansen <st02221@uib.no>
#
# === Copyright
#
# Copyright 2012 UiB
#
class httpd (
  $ensure,
  $user           = $httpd::params::user,
  $service        = $httpd::params::service,
  $packages       = $httpd::params::packages,
  $replace        = $httpd::params::replace,
  $server_admin   = $httpd::params::server_admin,
  $doc_root       = $httpd::params::doc_root,
  $config_dir     = $httpd::params::config_dir,
  $server_dns     = $httpd::params::server_dns,
) inherits httpd::params {

  # Install packages
  package {
    $packages:
      ensure => installed
  }
  
  # Start service 
  service { $service:
    ensure     => running, 
    enable     => true,
  }

  # Remove package garbage
  file { "${config_dir}/conf.d/welcome.conf":
    ensure => absent,
    require => Package[$packages]
  }
  
  # Main httpd conf
  file { 'main_conf':
    path    => "${config_dir}/conf/httpd.conf",
    ensure  => present,
    mode    => '0644',
    owner   => root,
    group   => root,
    content => template("httpd/conf/httpd.conf.erb"),
    replace => $replace
  }
    
  # Create vhosts.d folder
  file { 'vhosts_dir':
    path => "${config_dir}/vhosts.d",
    ensure => directory,
    mode   => '0755',
    owner  => root,
    group  => root
  }

  # IPv6
  if $::ipaddress6 {
    $ipv6_addr = $::ipaddress6
  } else {
    $ipv6_addr = false
  }

  # This file will set up virtual hosts
  file { 'vhosts_inc':
    path =>  "${config_dir}/conf.d/vhost-eth0.conf",
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    content => template("httpd/conf.d/vhosts-eth0.conf.erb"),
    replace => $replace,
  }

  # Create a dummy default page with hostname
  file { 'default_page':
    path => "${doc_root}/index.html",
    content => $::fqdn,
    replace => false,
  }
  
  # Set up resource dependencies (Resource chaining)
  Package[$packages] -> File['vhosts_inc'] -> Service[$service]
  Package[$packages] -> File['main_conf'] -> Service[$service]
  Package[$packages] -> File['vhosts_dir'] -> Service[$service]
  Package[$packages] -> File['default_page']
  
  # Vagrant or local machine hack
  if $fqdn == 'privnett.uib.no' {
    host { 'privnett.uib.no':
      ensure => present,
      ip => $::ipaddress
    }
    Host['privnett.uib.no'] -> Service[$service]
  }
}
