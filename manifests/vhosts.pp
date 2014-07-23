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
#   * directory directive
# See template for more options.
#
# === Examples
#
# httpd::vhosts { 'mysite':
#   service_name => 'mysite.example.com'
#   doc_root => /var/www/html
#   settings => { 
#     directory_path => /var/www/html,
#     directory => {
#       AllowOverride =>  all,
#       Order => 'deny,allow',
#       Deny => 'from all',
#       Allow => 'from 129.177.'
#     }
#   }
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
  $settings = ''
) {

  # Validate that service alias is an array
  validate_array($service_alias)

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