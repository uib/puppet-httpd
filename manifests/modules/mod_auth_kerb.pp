class httpd::modules::mod_auth_kerb(
  $config_dir     = $::httpd::config_dir,
  $mod_config_dir = $::httpd::mod_config_dir,
  $version        = $::httpd::version
) {

  # Install packages
  package { 'mod_auth_kerb':
    ensure => installed
  }

  $mod_config_path = $version? {
    22 => "${mod_config_dir}/auth_kerb.conf",
    24 => "${mod_config_dir}/10-auth_kerb.conf",
    default => "${mod_config_dir}/10-auth_kerb.conf",
  }

  file { $mod_config_path:
    ensure => present,
    notify => Class['::httpd::service']
  }

}
