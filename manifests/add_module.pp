define httpd::add_module(){
  class { "httpd::modules::${name}": }
}