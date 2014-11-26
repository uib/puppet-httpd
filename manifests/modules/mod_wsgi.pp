class httpd::modules::mod_wsgi(
  $config_dir   = $httpd::config_dir,
  $module_path  = 'modules',
  $socket_path  = undef
) {

  # Install packages
  package { 'mod_wsgi':
    ensure => installed
  }

  file { 'wsgi_conf':
    path => "${config_dir}/conf.d/wsgi.conf",
    ensure => present,
    content => template('httpd/conf.d/mod_wsgi.conf.erb'),
    replace => $replace,
    notify  => Class['httpd::service']
  }
}
