# == Class: httpd::module::mod_ssl
#
# This add SSL support for apache httpd
#
# === Parameters
#
# [*ssl_keys*]
#   This is used for the name of the .crt and .key files. Default to ::fqdn
#   Set this to 'localhost' to use the precreated self signed certificate
#
#
# === Examples
#
#  class { 'httpd::module::mod_ssl':
#    ssl_keys => 'localhost'
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
  $ssl_keys       = $::httpd::ssl_keys,
  $cachain        = $::httpd::cachain,
  $cachain_source = $::httpd::cachain_source,
  $server_dns     = $::httpd::server_dns,
  $config_dir     = $::httpd::config_dir,
  $mod_config_dir = $::httpd::mod_config_dir,
  $version        = $::httpd::version,
  $replace        = $::httpd::replace,
  $ipv6_addr      = $::httpd::ipv6_addr,
  $interface      = $::httpd::interface,
  $scl            = $::httpd::scl,
  $ssl_key_group  = 'root',
  $package        = 'mod_ssl'
) {

  case $interface {
    eth0: { $vhost_ip = $::ipaddress_eth0 }
    eth1: { $vhost_ip = $::ipaddress_eth1 }
    eth2: { $vhost_ip = $::ipaddress_eth2 }
    default: {$vhost_ip = $::ipaddress}
  }

  # Install packages
  package { $package:
    ensure => installed
  }

  File {
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    ensure  => present,
  }

  # This file will set up virtual hosts
  file { "${config_dir}/conf.d/vhost-https-eth0.conf":
    content => template("${module_name}/conf.d/${version}/vhosts-https-eth0.conf.erb"),
    replace => $replace,
    require => Package[$package],
    notify  => Class['::httpd::service']
  }

  file { 'ssl_inc':
    ensure  => present,
    path    =>  "${config_dir}/conf.d/ssl-eth0.inc",
    content => template('httpd/conf.d/ssl-eth0.inc.erb'),
    replace => $replace,
    require => Package[$package],
    notify  => Class['::httpd::service']
  }

  file { "${config_dir}/conf.d/ssl.conf":
    content => template("${module_name}/conf.d/${version}/ssl.conf.erb"),
    replace => $replace,
    require => Package[$package]
  }

  file { 'ssl_crt':
    path    => "/etc/pki/tls/certs/${ssl_keys}.crt",
    require => Package[$package]
  }
  file { 'ssl_key':
    path    => "/etc/pki/tls/private/${ssl_keys}.key",
    mode    => $ssl_key_group? {
      'root'  => '0600',
      default => '0640'
    },
    group   => $ssl_key_group,
    require => Package[$package]
  }

  if $cachain_source {
    file { 'cachain':
      ensure  => file,
      path    => '/etc/pki/tls/certs/cachain.pem',
      source  => "puppet:///modules/${cachain_source}",
      require => Package[$package]
    }
  }

  if $version >= 24 {
    file { "${mod_config_dir}/00-ssl.conf":
      source    => "puppet:///modules/${module_name}/conf.modules.d/${version}/00-ssl.conf"
    }
  }

}
