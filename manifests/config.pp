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
  $config_dir             = $::httpd::config_dir,
  $mod_config_dir         = $::httpd::mod_config_dir,
  $core_modules_conf_path = $::httpd::core_modules_conf_path,
  $log_level              = $::httpd::log_level,
  $replace                = $::httpd::replace,
  $doc_root               = $::httpd::doc_root,
  $version                = $::httpd::version,
  $vhost_ip               = $::httpd::vhost_ip
) {

  File {
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    notify  => Class['::httpd::service']
  }

  # Main httpd conf
  file { 'main_conf':
    path    => "${config_dir}/conf/httpd.conf",
    content => template("${module_name}/conf/httpd${version}.conf.erb"),
    replace => $replace,
  }

  # Create vhosts.d folder
  file { 'vhosts_dir':
    path    => "${config_dir}/vhosts.d",
    ensure  => directory,
    mode    => '0755',
    notify  => undef
  }

  # This file will set up virtual hosts
  file { 'vhosts_inc':
    path    => "${config_dir}/conf.d/vhost-eth0.conf",
    content => template("${module_name}/conf.d/${version}/vhosts-eth0.conf.erb"),
    replace => $replace,
  }

  # vhosts.d include file
  file { "${config_dir}/conf.d/zz_include.conf":
    source => "puppet:///modules/${module_name}/conf.d/${version}/zz_include.conf"
  }

  # Disable default welcome page
  file { "${config_dir}/conf.d/welcome.conf":
    source => "puppet:///modules/${module_name}/conf.d/${version}/welcome.conf"
  }

  # Create a dummy default page with hostname
  file { 'default_page':
    path      => "${doc_root}/index.html",
    content   => $::fqdn,
    replace   => false,
    notify    => undef
  }

  # This file will set extra core modules that is enabled
  concat { $core_modules_conf_path:
    owner   => 'root',
    group   => 'root',
    replace => true,
  }
  concat::fragment { "header":
    target  => $core_modules_conf_path,
    content => "# This file is managed by Puppet!\n",
    order   => 01,
  }

  # Version specific config
  if $version >= 24 {
    # Default files in conf.d
    file { "${config_dir}/conf.d/autoindex.conf":
      source => "puppet:///modules/${module_name}/conf.d/${version}/autoindex.conf"
    }
    file { "${config_dir}/conf.d/userdir.conf":
      source => "puppet:///modules/${module_name}/conf.d/${version}/userdir.conf"
    }
    # Modules
    file { "${mod_config_dir}/00-base.conf":
      source => "puppet:///modules/${module_name}/conf.modules.d/${version}/00-base.conf"
    }
    file { "${mod_config_dir}/00-dav.conf":
      source => "puppet:///modules/${module_name}/conf.modules.d/${version}/00-dav.conf"
    }
    file { "${mod_config_dir}/00-lua.conf":
      source => "puppet:///modules/${module_name}/conf.modules.d/${version}/00-lua.conf"
    }
    file { "${mod_config_dir}/00-mpm.conf":
      source => "puppet:///modules/${module_name}/conf.modules.d/${version}/00-mpm.conf"
    }
    file { "${mod_config_dir}/00-proxy.conf":
      source => "puppet:///modules/${module_name}/conf.modules.d/${version}/00-proxy.conf"
    }
    file { "${mod_config_dir}/00-systemd.conf":
      source => "puppet:///modules/${module_name}/conf.modules.d/${version}/00-systemd.conf"
    }
    file { "${mod_config_dir}/01-cgi.conf":
      source => "puppet:///modules/${module_name}/conf.modules.d/${version}/01-cgi.conf"
    }
  }

}
