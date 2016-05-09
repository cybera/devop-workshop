#
# Cookbook Name:: website
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package [ "apache2", 
          "libapache2-mod-passenger", 
          "libxml2-dev",
          "build-essential",
          "zlib1g-dev",
          "ruby-full",
          "libsqlite3-dev",
          "ruby-bundler" ]

template "/etc/apache2/sites-available/website.conf" do
  source 'etc/apache2/sites-available/website.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

service "apache2"

apache_site "website"
apache_module "passenger"

execute "bundle install" do
  cwd node[:website][:path]
  not_if "bundle check"
end