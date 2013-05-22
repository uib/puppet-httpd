class httpd::modules::mod_wsgi(
  $config_dir   = $httpd::params::config_dir,
  $service      = $httpd::params::service
) inherits httpd::params {

  # Install packages
  package { 'mod_wsgi':
    ensure => installed
  }

  file { 'wsgi_conf':
    path => "${config_dir}/conf.d/wsgi.conf",
    ensure => present,
    notify => Service[$service]
  }
}
