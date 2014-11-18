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
# [*type*]
#   Template type. Must match template name.
#
# [*settings*]
#   Hiera hash with optional directive settings:
#   * php_admin_value
#   * php_admin_flag
#   * directory
#   * location
#   * custom directive
#
#   See template for more options.
#
# === Examples
#
# httpd::vhosts { 'mysite':
#   service_name => 'mysite.example.com'
#   doc_root => /var/www/html
# }
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
  $service_alias = [],
  $use_ssl = false,
  $type = 'base',
  $settings = '',
  $port = '80',
  $ssl_port = '443'
) {

  # Validate that service alias is an array
  validate_array($service_alias)

  file { "/etc/httpd/vhosts.d/${name}.conf":
    path    => "/etc/httpd/vhosts.d/${name}.conf",
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 0644,
    content => template("${module_name}/vhosts.d/${$type}.conf.erb"),
    notify  => Class['httpd::service'],
  }

}
