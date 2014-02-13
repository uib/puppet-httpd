# == Class: httpd::vhosts
#
# Add a new vhost to vhosts.d
#
# === Parameters
#
# [*service_name*]
#
# [*doc_root*]
#
#
# === Examples
#
#
# === Authors
#
# Raymond Kristiansen <st02221@uib.no>
#
# === Copyright
#
# Copyright 2014 UiB
#
define httpd::vhosts(
  $service_name,
  $doc_root,
  $use_ssl = false,
  $type = 'base',
  $settings = ''
) {

  file { "${name}.conf":
    path    => "/etc/httpd/vhosts.d/${name}.conf",
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 0644,
    content => template("${module_name}/vhosts.d/${$type}.conf.erb"),
    notify  => Class['httpd::service'],
  }

}