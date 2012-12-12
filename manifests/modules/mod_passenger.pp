class httpd::modules::mod_passenger(
  $config_dir   = $httpd::params::config_dir,
  $service      = $httpd::params::service
) inherits httpd::params {

  # Install packages
  package { 'mod_passenger':
    ensure => installed
  }

  file { 'passenger_conf':
    path => "${config_dir}/conf.d/passenger.conf",
    ensure => present,
    notify => Service[$service]
  }
}
