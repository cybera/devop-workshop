#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install -y git python-pip

# install the chef development kit
wget -P /tmp https://packages.chef.io/stable/ubuntu/12.04/chefdk_0.18.26-1_amd64.deb
sudo dpkg -i /tmp/chefdk_0.18.26-1_amd64.deb 

# install chef-zero server
sudo apt-get install --reinstall -y chef-zero

# these are needed to build the nokogiri gem, used by the knife-openstack gem
sudo apt-get install -y build-essential ruby-dev zlib1g-dev

# Needed for building python packages
sudo apt-get install -y python-dev libffi-dev libssl-dev

# Install openstackclient via pip since ubuntu version is outdated
sudo pip install pbr jinja2 requests[security] python-openstackclient

# Workaround for pycparser issue: https://github.com/pyca/cryptography/issues/3187
sudo pip install --upgrade pip
sudo pip install git+https://github.com/eliben/pycparser@release_v2.14

# build and install the knife-openstack gem
cd /tmp
git clone https://github.com/opscode/knife-openstack.git
cd knife-openstack
gem build knife-openstack.gemspec
GEM=$(find /tmp -name '*.gem')
chef gem install $GEM --no-ri --no-rdoc

# some useful directories
mkdir -p ~/.chef
mkdir -p ~/.credentials

# create an empty cloud credentials file.  This will be replaced by
# the users actual credential file
touch ~/.credentials/openrc.sh

# for convienience, we'll automatically source the cloud credential file.
echo "source ~/.credentials/openrc.sh" >> ~/.bashrc
echo "bash /usr/local/bin/run-chef-zero" >> ~/.bashrc

# create a chef knife configuration file
# notice we're using the same identity file for both chef and openstack
cat << EOF > ~/.chef/knife.rb
chef_repo = File.join(File.dirname(__FILE__), "..")
cookbook_path ["#{chef_repo}/devop-workshop/chef/cookbooks"]
chef_server_url "http://<IP_ADDRESS>:8889" 
node_name "workshop"
client_key "#{ENV['HOME']}/.ssh/id_rsa"
cache_type "BasicFile"
cache_options :path => "#{chef_repo}/.chef/checksums"
knife[:ssh_identity_file] = "#{ENV['HOME']}/.ssh/id_rsa"
knife[:openstack_ssh_key_id] = "workshop" 
knife[:network] =  false
knife[:ssh_user] = "ubuntu"
knife[:flavor] = "m1.large"
knife[:editor] = "vi"
knife[:image] = "Ubuntu 16.04"
knife[:server_create_timeout] = 30
knife[:openstack_auth_url] = "#{ENV['OS_AUTH_URL']}/tokens"
knife[:openstack_password] = ENV['OS_PASSWORD']
knife[:openstack_tenant] = ENV['OS_TENANT_NAME']
knife[:openstack_username] = ENV['OS_USERNAME']
EOF


cat << EOF > ~/.ssh/config
UserKnownHostsFile=/dev/null
StrictHostKeyChecking=no
EOF


# generate and install openstack ssh keys
sudo tee /usr/local/bin/add-identity > /dev/null << EOF
echo
echo "Whups, careful!  This will replace your current SSH default identity"
echo "and your OpenStack 'workshop' keypair."
read -p "Are you sure? (enter 'y' to continue) " -r
echo
if [[ ! \$REPLY  =~ ^[Yy]\$ ]]
then
    echo "okay, I won't change a thing"
    exit 1
fi
rm ~/.ssh/id_rsa
ssh-keygen -N '' -f ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa
ssh-keygen -f ~/.ssh/id_rsa -y > ~/.ssh/id_rsa.pub
nova keypair-delete workshop 2>&1 > /dev/null
nova keypair-add --pub-key ~/.ssh/id_rsa.pub workshop
EOF
sudo chmod +x /usr/local/bin/add-identity


# write a little script to configure and start chef-zero
sudo tee /usr/local/bin/run-chef-zero > /dev/null << EOF
IP=\$(ifconfig | grep 'inet addr:10.' | awk '/inet addr/{print substr(\$2,6)}')
sed -i "s/<IP_ADDRESS>/\${IP}/" .chef/knife.rb 
chef-zero --host \${IP} --daemon 
EOF
sudo chmod +x /usr/local/bin/run-chef-zero


# simple utility to de-emphasise our use of Chef.  We
# don't want Chef to be the focus of this workshop
sudo tee /usr/local/bin/chef-upload > /dev/null << EOF
CHEF="/home/ubuntu/devop-workshop/chef"

for c in \$(ls \$CHEF/cookbooks); do 
knife cookbook upload \$c;
done

for r in \$(find \$CHEF/roles -name *.json); do
    knife role from file \$r;
done
EOF
sudo chmod +x /usr/local/bin/chef-upload


# write a check the workstation has been configured by the user
# Notice this creates a python script.  There's no reason for this
# other to demonstrate that you don't have to use a single
# scripting language for everything you do.
sudo tee /usr/local/bin/check_workshop_config > /dev/null << EOF
#! /usr/bin/env python

import os.path

credentials = '/home/ubuntu/.credentials/openrc.sh'
key = '/home/ubuntu/.ssh/id_rsa'

# check cloud credentials exists and is not just an empty file
if not os.path.isfile(credentials) or 'OS_AUTH_URL' not in open(credentials).read():
  print "\nHmmm... I can't find your cloud credentials, or maybe it's just empty."
  print "You should copy them to '%s'\n" % (credentials)

# check the default ssh identity file exists and has correct mode
if not os.path.isfile(key):
  print "\nHey, it looks like you haven't set up your default ssh identity file."
  print "You can either copy an existing RSA pem key to '%s', or create a new one:" % (key)
  print "\n    ssh-keygen -N '' -f ~/.ssh/id_rsa \n"
else:
  mode = oct(os.stat(key).st_mode & 0777)
  if mode != "0400":
    print "\nWhups, you should change the mode of your default ssh key:"
    print "\n    chmod 400 ~/.ssh/id_rsa \n"
EOF
sudo chmod +x /usr/local/bin/check_workshop_config

# call our configuration check upon login
cat << EOF >> ~/.profile
check_workshop_config
EOF

# git clone devop-workshop repository
cd /home/ubuntu
git clone https://github.com/cybera/devop-workshop.git

# setup devop-tool from devop-workshop repository
echo 'eval "$(/home/ubuntu/devop-workshop/devop-tool/bin/devops init -)"' >> ~/.bashrc
