# -----------------------------------------------------------------------
# Cookbook Name:: sqlite
# Recipe:: default
#
# Copyright 2016, Cybera, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
# -----------------------------------------------------------------------

# install sqlite3 package
package "sqlite3"

# create installation directory
directory node[:db][:data] do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end

# create db population script
template "#{node[:db][:data]}/coffee.sql" do
  source "coffee.sql.erb"
  mode 0755
end


# call creation script
execute 'create database' do
  command "sqlite3 coffee.db3 < #{node[:db][:data]}/coffee.sql"
  not_if { File.exist?("#{node[:db][:data]}/coffee.db3")}
end


# create backup dir
directory node[:db][:backups] do
  owner "root"
  group "root"
  mode "0755"
  recursive true
  action :create
end


# write backup script
template "#{node[:db][:utils]}/sqlite_backup" do
  source "backup.py.erb"
  mode 0755
end


# create cron task to call backup
cron "backup sqlite database" do
  hour "*"
  minute "27"
  command "sqlite_backup #{node[:db][:data]}/coffee.db3 /backups > #{node[:db][:logs]}backup.log 2>&1"
end
