#!/bin/bash
yum update -y

rpm -ivh http://yum.puppetlabs.com/puppet5-release-el-7.noarch.rpm

yum install -y puppet-agent puppet-bolt git

cd /etc/puppetlabs/code/environments
git clone https://github.com/pookey/puppet-example.git myenv
cd /etc/puppetlabs/code/environments/myenv
/opt/puppetlabs/bin/bolt puppetfile install
/opt/puppetlabs/bin/puppet apply --environment myenv /etc/puppetlabs/code/environments/myenv/manifests/site.pp
