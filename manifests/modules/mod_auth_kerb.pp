class httpd::modules::mod_auth_kerb(
  $config_dir     = $httpd::config_dir,
  $service        = $httpd::service,
  $group          = $httpd::group,
  $manage_keytab  = true
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

  # Ensure that the name, permission and mode of the keytab is set up correct
  if $manage_keytab {
    file { '/etc/httpd/keytabs/http.keytab':
      ensure  => present,
      owner   => root,
      group   => $group,
      mode    => 0640
    }
  }
}
