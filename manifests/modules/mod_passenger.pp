class httpd::modules::mod_passenger(
  $config_dir   = $httpd::config_dir,
  $service      = $httpd::service
) {

  # Install packages
  package { 'mod_passenger':
    ensure => latest
  }

  file { 'passenger_conf':
    path => "${config_dir}/conf.d/passenger.conf",
    ensure => present,
    notify => Class['httpd::service']
  }
}
