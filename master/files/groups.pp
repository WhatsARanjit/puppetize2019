node_group { 'Web servers':
  ensure               => 'present',
  classes              => {
  'apache' => {

  },
  'apache::mod::php' => {

  },
  'wordpress' => {
    'db_host' => '$trusted["extensions"]["pp_application"]',
    'install_dir' => '/var/www/html'
  }
},
  environment          => 'production',
  override_environment => false,
  parent               => 'All Nodes',
  rule                 => ['and',
  ['=',
    ['trusted', 'extensions', 'pp_role'],
    'webserver']],
}

node_group { 'DB servers':
  ensure               => 'present',
  classes              => {
  'mysql::bindings' => {
    'php_enable' => true
  },
  'mysql::server' => {

  }
},
  environment          => 'production',
  override_environment => false,
  parent               => 'All Nodes',
  rule                 => ['and',
  ['=',
    ['trusted', 'extensions', 'pp_role'],
    'dbserver']],
}
