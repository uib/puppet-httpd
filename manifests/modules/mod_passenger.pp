class httpd::modules::mod_passenger(
  $config_dir     = $::httpd::config_dir,
  $mod_config_dir = $::httpd::mod_config_dir,
  $version        = $::httpd::version
) {

  # Install packages
  package { 'mod_passenger':
    ensure => latest
  }

  file { 'passenger_conf':
    path => "${config_dir}/conf.d/passenger.conf",
    ensure => present,
    notify => Class['::httpd::service']
  }
}
