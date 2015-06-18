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
  $cachain_source = undef,
  $cachain        = 'cachain.pem',
  $config_dir = $::osfamily ? { RedHat => '/etc/httpd/', default => '', },
  $user = $::osfamily ? { default => 'apache', },
  $group = $::osfamily ? { default => 'apache', },
  $log_level = 'warn',
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
  $listen_ports = { 80 => '' },
  $core_modules = hiera_hash('httpd::core_modules', {})
)  {

  validate_hash($listen_ports)

  if has_interface_with($interface) {
    case $interface {
      eth0: { $vhost_ip = $::ipaddress_eth0 }
      eth1: { $vhost_ip = $::ipaddress_eth1 }
      eth2: { $vhost_ip = $::ipaddress_eth2 }
      default: {$vhost_ip = $::ipaddress}
    }
  } else {
    err("httpd::interface is set to ${interface} but is missing!")
    $vhost_ip = $::ipaddress
  }

  # version
  if $::osfamily == 'RedHat' {
    $version = $::operatingsystemmajrelease? {
      6 => 22,
      7 => 24,
      default => 24
    }
  } elsif $::osfamily == 'Debian' {
    $version = 24
  }

  # modules config directory
  if $::osfamily == 'RedHat' and $version == 24 {
    $mod_config_dir = "${config_dir}conf.modules.d"
  } elsif $::osfamily == 'RedHat' and $version == 22 {
    $mod_config_dir = "${config_dir}conf.d"
  }

  # core modules config file
  $core_modules_conf_path = $version? {
    22 => "${mod_config_dir}/core_modules.conf",
    24 => "${mod_config_dir}/05-core_modules.conf",
    default => "${mod_config_dir}/05-core_modules.conf"
  }

  # add core modules
  create_resources('httpd::modules::core_modules', $core_modules )

  class { '::httpd::install': } ->
  class { '::httpd::config': } ->
  class { '::httpd::service': }

}
