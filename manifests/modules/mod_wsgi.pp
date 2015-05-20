class httpd::modules::mod_wsgi(
  $config_dir     = $::httpd::config_dir,
  $mod_config_dir = $::httpd::mod_config_dir,
  $replace        = $::httpd::replace,
  $version        = $::httpd::version,
  $module_path    = 'modules',
  $socket_path    = undef
) {

  # Install packages 
  package { 'mod_wsgi':
    ensure => installed
  }

  $config_file = $version? {
    '22' => "${mod_config_dir}/wsgi.conf",
    '24' => "${mod_config_dir}/10-wsgi.conf",
    default => "${mod_config_dir}/10-wsgi.conf"
  }
  file { $config_file:
    ensure => present,
    content => template("${module_name}/conf.modules.d/10-wsgi.conf.erb"),
    replace => $replace,
    notify  => Class['::httpd::service']
  }

}
