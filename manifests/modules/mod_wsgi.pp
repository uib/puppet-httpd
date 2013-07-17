class httpd::modules::mod_wsgi(
  $config_dir   = $httpd::config_dir,
) {

  # Install packages
  package { 'mod_wsgi':
    ensure => installed
  }

  file { 'wsgi_conf':
    path => "${config_dir}/conf.d/wsgi.conf",
    ensure => present,
    notify => Class['httpd::service']
  }
}
