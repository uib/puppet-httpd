# == Class: httpd::service
#
# This sets up the Apache HTTPD service
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
class httpd::service(
  $user           = $httpd::user,
  $group          = $httpd::group,
  $service        = $httpd::service
) {
  # Start service 
  service { $service:
    ensure     => running, 
    enable     => true,
  }
}