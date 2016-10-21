include_recipe 'sensu::default'
include_recipe 'sensu::rabbitmq'
include_recipe 'sensu::redis'
include_recipe 'sensu::server_service'

sensu_client "localhost" do
  address "127.0.0.1"
  subscriptions ["website"]
end

sensu_handler "log" do
  type "pipe"
  command "echo $(date) -- Website is down >> /tmp/sensu.log"
  severities ["unknown", "warning", "critical"]
end

sensu_check "website" do
  command "curl localhost"
  handlers ["log"]
  subscribers ["website"]
  interval 5
end

sensu_handler "db-backups" do
  type "pipe"
  command "echo $(date) -- Hourly database backup not found >> /tmp/sensu.log"
  severities ["warning"]
end

sensu_check "check-recent-db-backup" do
  command "check-db-backup"
  handlers ["db-backups"]
  subscribers ["website"]
  interval 5
end

include_recipe 'sensu::client_service'
