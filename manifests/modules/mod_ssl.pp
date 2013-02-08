# == Class: httpd::module::mod_ssl
#
# This add SSL support for apache httpd
#
# === Parameters
#
# [*ssl_host*]
#   This is used for the name of the .crt and .key files. Default to ::fqdn
#   Set this to 'localhost' to use the precreated self signed certificate
#
#
# === Examples
#
#  class { 'httpd::module::mod_ssl':
#    ssl_host => 'localhost'
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
class httpd::modules::mod_ssl(
  $ssl_host        = $httpd::params::ssl_host,
  $server_dns      = $httpd::params::server_dns,
  $config_dir      = $httpd::params::config_dir
) inherits httpd::params {
  
  # Install packages
  package { 'mod_ssl':
    ensure => installed
  }
  
  # This file will set up virtual hosts
  file { 'vhosts_https':
    path =>  "${config_dir}/conf.d/vhost-https-eth0.conf",
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    content => template("httpd/conf.d/vhosts-https-eth0.conf.erb"),
    replace => $replace,
    require => Package['mod_ssl'],
    notify => Service[$service]
  }
  
  file { 'ssl_inc':
    path =>  "${config_dir}/conf.d/ssl-eth0.inc",
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    content => template("httpd/conf.d/ssl-eth0.inc.erb"),
    replace => $replace,
    require => Package['mod_ssl']
  }

  file { 'ssl_conf':
    path => "${config_dir}/conf.d/ssl.conf",
    ensure => file,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source    => "puppet:///modules/httpd/ssl.conf",
    replace => $replace,
    require => Package['mod_ssl']
  }

  file { 'ssl_crt':
    path => "/etc/pki/tls/certs/${server_dns}.crt",
    ensure => present,
    mode => '0644',
    require => Package['mod_ssl']
  }
  file { 'ssl_key':
    path => "/etc/pki/tls/private/${server_dns}.key",
    ensure => present,
    mode => '0600',
    require => Package['mod_ssl']
  }

  # Terena UiB CA chain
  file { 'cachain':
    path => "/etc/pki/tls/certs/cachain.pem",
    ensure => file,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source    => "puppet:///modules/httpd/cachain.pem",
    require => Package['mod_ssl']
  }
}

