#
# Cookbook Name:: website
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

execute "apt-get update"

include_recipe "lsyncd"

package [ "git",
          "apache2", 
          "libapache2-mod-passenger", 
          "libxml2-dev",
          "build-essential",
          "zlib1g-dev",
          "ruby-full",
          "libsqlite3-dev",
          "libpq-dev",
          "ruby-bundler" ]

gem_package 'bundler'

template "/etc/apache2/sites-available/website.conf" do
  source 'etc/apache2/sites-available/website.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

service "apache2"

apache_site "website"
apache_module "passenger"

directory node[:website][:path] do
  owner "ubuntu"
  group "ubuntu"
  mode "0755"
  action :create
end

git node[:website][:path] do
  repository "https://github.com/cybera/devop-workshop.git"
  reference "master"
  action :sync
end

execute "bundle install" do
  cwd node[:website][:path]
  not_if "bundle check"
end

