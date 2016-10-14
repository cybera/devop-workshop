#!/usr/bin/env bash

sudo apt-get update

# install the chef development kit
wget -P /tmp https://packages.chef.io/stable/ubuntu/12.04/chefdk_0.18.26-1_amd64.deb
sudo dpkg -i /tmp/chefdk_0.18.26-1_amd64.deb 

# install chef-zero server
sudo apt-get install -y chef-zero

# install the openstack command line client
sudo apt-get install -y python-novaclient
# these are needed to build the nokogiri gem, used by the knife-openstack gem
sudo apt-get install -y build-essential ruby-dev zlib1g-dev

# build and install the knife-openstack gem
cd /tmp
git clone https://github.com/opscode/knife-openstack.git
cd knife-openstack
gem build knife-openstack.gemspec
chef gem install knife-openstack/knife-openstack*.gem --no-ri --no-rdoc

# some useful directories
mkdir ~/.chef
mkdir ~/.credentials

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
cookbook_path "#{chef_repo}/chef/cookbooks"
chef_server_url "http://<IP_ADDRESS>:8889" 
node_name "workshop"
client_key "#{ENV['HOME']}/.ssh/id_rsa"
cache_type "BasicFile"
cache_options :path => "#{chef_repo}/chef/checksums"
knife[:ssh_identity_file] = "#{ENV['HOME']}/.ssh/id_rsa"
knife[:openstack_ssh_key_id] = "workshop" 
knife[:network] =  false
knife[:ssh_user] = "ubuntu"
knife[:flavor] = "m1.tiny"
knife[:editor] = "vi"
knife[:image] = "Ubuntu 16.04"
knife[:server_create_timeout] = 15
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
IP=\$(ifconfig | grep 10.2 | awk '/inet addr/{print substr(\$2,6)}')
sed -i "s/<IP_ADDRESS>/\${IP}/" .chef/knife.rb 
chef-zero --host \${IP} --daemon 
EOF
sudo chmod +x /usr/local/bin/run-chef-zero


# simple utility to de-emphasise our use of Chef.  We
# don't want Chef to be the focus of this workshop
sudo tee /usr/local/bin/chef-upload > /dev/null << EOF
CHEF="/home/ubuntu/devop-workshop/chef"

for c in \$(ls \$CHEF/cookbooks); do 
knife cookbook upload $c; 
done

for r in \$(find \$CHEF/roles -name *.json); do
    knife role from file $r;
done
EOF
sudo chmod +x /usr/local/bin/chef-upload
