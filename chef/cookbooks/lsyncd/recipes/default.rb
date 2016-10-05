#
# Cookbook Name:: lsyncd
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

service 'lsyncd' do
  action :nothing
end

package 'lsyncd' do
  action :install
  notifies :stop, resources(:service => "lsyncd"), :immediately
end

directory '/etc/lsyncd' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/etc/lsyncd/conf.d' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/etc/lsyncd/confs-available' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

template '/etc/lsyncd/lsyncd.conf.lua' do
  source 'etc/lsyncd/lsyncd.conf.lua.erb'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  notifies :restart, resources(:service => "lsyncd")
end

template '/etc/lsyncd/exclude.conf' do
  source 'etc/lsyncd/exclude.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  notifies :restart, resources(:service => "lsyncd")
end

node[:lsyncd][:rsync].each do |key,options|
    template "/etc/lsyncd/confs-available/rsync-#{key}.conf.lua" do
        source 'etc/lsyncd/confs-available/rsync.conf.lua.erb'
        owner 'root'
        group 'root'
        variables(
            :options => options
        )
        mode '0644'
        action :create
        notifies :restart, resources(:service => "lsyncd") if options[:enabled]
    end

    link "/etc/lsyncd/conf.d/rsync-#{key}.conf.lua" do
      to "/etc/lsyncd/confs-available/rsync-#{key}.conf.lua"
      link_type :symbolic
      notifies :restart, resources(:service => "lsyncd")
      only_if { options[:enabled] }
    end
end
