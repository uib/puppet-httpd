# == Class: httpd::install
#
# This install the Apache HTTPD server
#
# === Parameters
#
#
# === Authors
#
# Raymond Kristiansen <st02221@uib.no>
#
# === Copyright
#
# Copyright 2013 UiB
#
class httpd::install(
  $packages = $httpd::packages
) {

  # Install packages
  package { $packages:
      ensure => installed
  }

}