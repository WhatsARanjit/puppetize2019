{
  "console_admin_password": "${admin_password}"
  "puppet_enterprise::puppet_master_host": "%%{::trusted.certname}"
  "pe_install::puppet_master_dnsaltnames": [PUBLICDNS]
  "puppet_enterprise::profile::master::code_manager_auto_configure": true
  "puppet_enterprise::profile::master::r10k_remote": "https://github.com/WhatsARanjit/testrepo.git"
}
