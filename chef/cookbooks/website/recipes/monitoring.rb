include_recipe 'sensu::default'
include_recipe 'sensu::rabbitmq'
include_recipe 'sensu::redis'
include_recipe 'sensu::server_service'

sensu_client "localhost" do
  address "127.0.0.1"
  subscriptions ["website"]
end



include_recipe 'sensu::client_service'

