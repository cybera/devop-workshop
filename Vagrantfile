# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.synced_folder ".", "/var/www/html/website" do |f| 
    f.group = "www-data"
  end
  
  config.vm.network "forwarded_port", guest: 80, host: 8080

# config.vm.provision "shell", inline: <<-SHELL
#   sudo apt-get update
#   sudo apt-get install -y apache2
#   sudo apt-get install -y ruby-full
# SHELL

  config.vm.provision "chef_zero" do |chef|
    chef.cookbooks_path = "chef/cookbooks"
    chef.data_bags_path = "chef/data_bags"
    chef.nodes_path = "chef/nodes"
    chef.roles_path = "chef/roles"

    chef.add_role "website"
  end  
end
