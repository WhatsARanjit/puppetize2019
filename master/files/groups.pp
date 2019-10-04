node_group { 'Web servers':
  ensure               => 'present',
  environment          => 'production',
  override_environment => false,
  parent               => 'All Nodes',

  classes => {
    'mysql::bindings' => {
      'php_enable' => true
    },
    'apache' => {
      'mpm_module' => 'prefork'
    },
    'apache::mod::php' => {},
    'profiles::wordpress_web' => {},
  },
  data => {
    'wordpress' => {
      'db_password' => 'wordpress',
      'version'     => '5.2.3'
    }
  },
  rule => ['and',
    ['=',
      ['trusted', 'extensions', 'pp_role'],
      'webserver']
    ],
}

node_group { 'DB servers':
  ensure               => 'present',
  environment          => 'production',
  override_environment => false,
  parent               => 'All Nodes',
  
  classes => {
    'mysql::bindings' => {
      'php_enable' => true
    },
    'mysql::server' => {
      'override_options' => {
        'mysqld' => {
          'bind-address' => '$ipaddress',
        },
      },
    },
    'profiles::wordpress_db' => {}
  },
  rule => ['and',
  ['=',
    ['trusted', 'extensions', 'pp_role'],
    'dbserver']
  ],
}
