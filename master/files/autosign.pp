pe_ini_setting { 'policy-based autosigning':
  setting => 'autosign',
  path    => "${settings::confdir}/puppet.conf",
  section => 'master',
  value   => '/opt/puppetlabs/puppet/bin/autosign-validator',
}

class { 'autosign':
  ensure => 'latest',
  config => {
    'general' => {
      'loglevel' => 'INFO',
    },
    'jwt_token' => {
      'secret'   => 'thisshouldbesecret',
      'validity' => '7200',
    },
  },
}
