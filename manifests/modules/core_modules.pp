# Define httpd::core_modules
#
# Description:
#   Enables core apache modules, eg. mod_proxy
#   Values can be set in a hash in hiera or app class or both
#
#     - name   -- is the module name.
#     - order  -- determines the ordering of the LoadModule statements in the config file.
#                 higher number means later in the file.
#                 ordering is for all the data if pulled from multiple sources.
#                 some modules depends on other modules, beware the ordering.
#     - path   -- is the path to the module file.
#
#     Ex (from an app class):
#       $proxy_modules = {
#         'proxy_module'         => { 'order' => '80',
#                                     'path'  => 'modules/mod_proxy.so' },
#         'proxy_http_module'    => { 'order' => '82',
#                                     'path'  => 'modules/mod_proxy_http.so' },
#         'proxy_connect_module' => { 'order' => '83',
#                                     'path'  => 'modules/mod_proxy_connect.so' }
#       }
#
#       # Pull data from hiera.
#       $core_modules = hiera_hash('core_modules', {})
#       # Run the define for the hash given above.
#       create_resources('httpd::modules::core_modules', $proxy_modules)
#       # Run the define for the define for thre data pulled from hiera.
#       create_resources('httpd::modules::core_modules', $core_modules)
#
## LoadModule <%= @name %><%- unless @path.empty? %> <%= @path %><%- end %>

define httpd::modules::core_modules  (
  $config_dir   = $httpd::config_dir,
  $ensure       = 'installed',
  $order        = '50',
  $path         = undef,
)  {
  validate_re($ensure, "installed|absent", "Valid values are 'installed' or 'absent'")

  if $ensure == 'installed' {
    concat::fragment { "${name}":
      target  => "${config_dir}/conf.d/core_modules.conf",
      content => template("${module_name}/conf.d/core_modules.conf.erb"),
      order   => $order,
    }
  }
}
