# == Class: httpd::config
#
# This configure the basic Apache HTTPD vhost UiB setup
#
# === Parameters
#
#
# === Authors
#
# Raymond Kristiansen <st02221@uib.no>
#
# === Copyright
#
# Copyright 2013 UiB
#
class httpd::config(
  $config_dir   = $httpd::config_dir,
  $replace      = $httpd::replace,
  $doc_root     = $httpd::doc_root,
) {

  File {
    mode    => '0644',
    owner   => root,
    group   => root,
  }

  # Remove package garbage
  file { "${config_dir}/conf.d/welcome.conf":
    ensure => absent,
  }
  
  # Main httpd conf
  file { 'main_conf':
    path    => "${config_dir}/conf/httpd.conf",
    ensure  => present,
    content => template("httpd/conf/httpd.conf.erb"),
    replace => $replace,
    notify  => Class['httpd::service']
  }
    
  # Create vhosts.d folder
  file { 'vhosts_dir':
    path    => "${config_dir}/vhosts.d",
    ensure  => directory,
    mode    => '0755',
  }

  # This file will set up virtual hosts
  file { 'vhosts_inc':
    path    =>  "${config_dir}/conf.d/vhost-eth0.conf",
    ensure  => present,
    content => template("httpd/conf.d/vhosts-eth0.conf.erb"),
    replace => $replace,
    notify  => Class['httpd::service']
  }
  
  # vhosts.d include file
  file { 'include_conf':
    path    => "${config_dir}/conf.d/zz_include.conf",
    ensure  => present,
    source  => "puppet:///modules/httpd/zz_include.conf",
    replace => $replace
  }

  # Create a dummy default page with hostname
  file { 'default_page':
    path      => "${doc_root}/index.html",
    content   => $::fqdn,
    replace   => false,
  }

  # This file will set extra core modules that is enabled 
  concat { "${config_dir}/conf.d/core_modules.conf":
    owner   => 'root',
    group   => 'root',
    replace => true,
  }
  concat::fragment { "header":
    target  => "${config_dir}/conf.d/core_modules.conf",
    content => "# This file is managed by Puppet!\n",
    order   => 01,
  }

}
