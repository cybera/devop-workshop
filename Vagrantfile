# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 443, host: 8443 

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL

  config.vm.synced_folder ".", "/var/www/html/website", :group => "www-data"
  
  config.vm.provision "chef_zero" do |chef|
    chef.cookbooks_path = "chef/cookbooks"
    chef.data_bags_path = "chef/data_bags"
    chef.nodes_path = "chef/nodes"
    chef.roles_path = "chef/roles"

    chef.add_role "website"
  end
end
