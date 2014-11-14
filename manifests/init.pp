# == Class: httpd
#
# This sets up a simple Apache HTTPD server
#
# === Parameters
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
#  class { 'httpd': }
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
  $server_admin   = "apache@uib.no",
  $doc_root       = "/var/www/html",
  $replace        = true,
  $server_dns     = $::fqdn,
  $ssl_keys       = $::fqdn,
  $config_dir = $::osfamily ? { RedHat => '/etc/httpd/', default => '', },
  $user = $::osfamily ? { default => 'apache', },
  $group = $::osfamily ? { default => 'apache', },
  $ipv6_addr = $::ipaddress6 ? { undef => false, default => $::ipaddress6 },
  $interface = undef,
  $service = $::osfamily ? {
    Debian => 'www-data',
    RedHat => 'httpd',
    default => '',
  },
  $packages = $::osfamily ? {
    Debian => 'apache2',
    RedHat => 'httpd',
    default => '',
  },
  $prefork_settings = {},
)  {

  case $interface {
    eth0: { $vhost_ip = $::ipaddress_eth0 }
    eth1: { $vhost_ip = $::ipaddress_eth1 }
    eth2: { $vhost_ip = $::ipaddress_eth2 }
    default: {$vhost_ip = $::ipaddress}
  }

  class { 'httpd::install': } ->
  class { 'httpd::config': } ->
  class { 'httpd::service': }
  
}
