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
# [*config_dir*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
#
# === Examples
#
#  class { 'httpd':
#    ensure => true,
#    server_admin => 'webmaster@uib.no'
#  }
#
# === Authors
#
# Raymond Kristiansen <st02221@uib.no>
#
# === Copyright
#
# Copyright 2013 UiB
#
class httpd (
  $user           = $httpd::params::user,
  $group          = $httpd::params::group,
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
    replace => $replace,
    notify  => Service[$service]
  }
    
  # Create vhosts.d folder
  file { 'vhosts_dir':
    path => "${config_dir}/vhosts.d",
    ensure => directory,
    mode   => '0755',
    owner  => root,
    group  => root
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
    notify => Service[$service]
  }
  
  # vhosts.d include file
  file { 'include_conf':
    path => "${config_dir}/conf.d/zz_include.conf",
    ensure => present,
    mode   => '0644',
    owner  => root,
    group  => root,
    source    => "puppet:///modules/httpd/zz_include.conf",
    replace => $replace
  }

  # Create a dummy default page with hostname
  file { 'default_page':
    path => "${doc_root}/index.html",
    content => $::fqdn,
    replace => false,
    require => Package[$packages]
  }
  
  # Set up resource dependencies (Resource chaining)
  Package[$packages] -> File['vhosts_inc'] -> Service[$service]
  Package[$packages] -> File['main_conf'] -> Service[$service]
  Package[$packages] -> File['vhosts_dir'] -> Service[$service]
  Package[$packages] -> File['include_conf'] -> Service[$service]
  
}
