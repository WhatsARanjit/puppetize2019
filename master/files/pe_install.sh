#!/bin/bash

# Run PE installer
cd $(find -type d -name "puppet-enterprise-*")
sudo ./puppet-enterprise-installer -c /tmp/pe.conf
sudo puppet module install WhatsARanjit/node_manager --modulepath /opt/puppetlabs/puppet/modules

# Run agent
sudo puppet plugin download
sudo puppet agent -t
if [ $? -eq 0 ] || [ $? -eq 2 ]; then
  /bin/true
fi

# Set server
export SERVER=$(sudo puppet config print server)

# Add new user to Code Deployer role
sudo curl -k \
  -H 'Content-Type: application/json' \
  --tlsv1 \
  --cert   $(sudo puppet config print hostcert) \
  --key    $(sudo puppet config print hostprivkey) \
  --cacert $(sudo puppet config print localcacert) \
  -X POST \
  -d '{ "login": "deploy", "password": "puppetlabs", "email": "deploy@test.com", "display_name": "Deploy User", "role_ids": [4] }' \
  "https://${SERVER}:4433/rbac-api/v1/users"

# Fetch token for deploy user
sudo curl -k \
  -H 'Content-Type: application/json' \
  --tlsv1 \
  --cert   $(sudo puppet config print hostcert) \
  --key    $(sudo puppet config print hostprivkey) \
  --cacert $(sudo puppet config print localcacert) \
  -X POST \
  -d '{ "login": "deploy", "password": "puppetlabs", "lifetime": "0" }' \
  "https://${SERVER}:4433/rbac-api/v1/auth/token" | tee token.json
sudo cut -d '"' -f4 token.json | tee ~/.puppetlabs/token

# Trigger code deploy
sudo /opt/puppetlabs/bin/puppet-code deploy production --wait

# Update classes
sudo puppet node_manager classes --update

# Create web and DB groups
cd /tmp
sudo puppet apply groups.pp

# Setup autosignining
sudo puppet apply autosign.pp
sudo service pe-puppetserver reload
