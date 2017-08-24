#
# Cookbook:: rabbitmq
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

bash "Add Apt Source List" do
  user "root"
  code <<-EOS
  echo 'deb http://www.rabbitmq.com/debian/ testing main' >> /etc/apt/sources.list.d/rabbitmq.list
  EOS
  not_if "grep -q www.rabbitmq.com /etc/apt/sources.list.d/rabbitmq.list"
end

execute "Insert Apt Key" do
 command "curl https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -"
end

execute "apt-get-update" do
  command "apt-get update"
end

apt_update 'update'

apt_package 'rabbitmq-server' do
  action :install
end

execute "Enable rabbitmq_management" do
  command "rabbitmq-plugins enable rabbitmq_management"
  user "root"
  action :run
  not_if "rabbitmq-plugins list -e | grep ' rabbitmq_management '"
end

service "rabbitmq-server" do
  stop_command "/usr/sbin/rabbitmqctl stop"
  action [:enable, :start]
end

execute "Adding RabbitMQ user" do
 command "rabbitmqctl add_user admin password"
 command "rabbitmqctl set_user_tags admin administrator"
 command "rabbitmqctl set_permissions -p / admin '.*' '.*' '.*'"
end

service 'rabbitmq-server' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :restart ]
end

execute 'Login Details for RabbitMQ Console' do 
   command "echo 'user: admin  password: password'" 
end 

