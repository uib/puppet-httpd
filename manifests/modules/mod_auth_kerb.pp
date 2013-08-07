class httpd::modules::mod_auth_kerb(
  $config_dir   = $httpd::config_dir,
  $service      = $httpd::service
) {

  # Install packages
  package { 'mod_auth_kerb':
    ensure => installed
  }

  file { 'auth_kerb_conf':
    path => "${config_dir}/conf.d/auth_kerb.conf",
    ensure => present,
    notify => Class['httpd::service']
  }
}
