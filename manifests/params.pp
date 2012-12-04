# == Class: httpd::params
#
# Params for the Apache HTTPD web server
#
# === Authors
#
# Raymond Kristiansen <st02221@uib.no>
#
# === Copyright
#
# Copyright 2012 UiB
#
class httpd::params {
  $server_admin   = "apache@uib.no"
  $doc_root       = "/var/www/html"
  $replace        = true
  
  $packages = $::osfamily ? {
    Debian => 'apache2',
    RedHat => 'httpd',
    default => '',
  }
  $config_dir = $::osfamily ? {
    RedHat => '/etc/httpd/',
    default => '',
  }
  $user = $::osfamily ? {
    Debian => 'apache',
    RedHat => 'httpd',
    default => '',
  }
  $service = $::osfamily ? {
    Debian => 'www-data',
    RedHat => 'httpd',
    default => '',
  }

}