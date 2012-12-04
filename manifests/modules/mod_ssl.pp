class httpd::modules::mod_ssl(
) inherits httpd::params {
  
  $packages = $::osfamily ? {
    RedHat => 'mod_ssl',
    default => '',
  }
  
  # Install packages
  package { 'mod_ssl':
    ensure => installed
  }
  
  # This file will set up virtual hosts
  file { 'vhosts_https':
    path =>  "${config_dir}/conf.d/vhost-https-eth0.conf",
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    content => template("httpd/conf.d/vhosts-https-eth0.conf.erb"),
    replace => $replace,
  }
  
  file { 'ssl_inc':
    path =>  "${config_dir}/conf.d/ssl-eth0.inc",
    ensure => present,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    content => template("httpd/conf.d/ssl-eth0.inc.erb"),
    replace => $replace,
  }

  file { 'ssl_conf':
    path => "${config_dir}/conf.d/ssl.conf",
    ensure => file,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source    => "puppet:///modules/httpd/ssl.conf",
    replace => $replace,
  }
    
  # Placeholders
  file { 'ssl_crt':
    path => "/etc/pki/tls/certs/${fqdn}.crt",
    ensure => present
  }
  file { 'ssl_key':
    path => "/etc/pki/tls/private/${fqdn}.key",
    ensure => present
  }
  
  # Terena UiB CA chain
  file { 'cachain':
    path => "/etc/pki/tls/certs/cachain.pem",
    ensure => file,
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source    => "puppet:///modules/httpd/cachain.pem"
  }
  
  Package[$packages] -> File['cachain']
  Package[$packages] -> File['ssl_conf']
  
}