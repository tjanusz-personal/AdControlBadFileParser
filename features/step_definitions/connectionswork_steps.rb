require './ProdDriveConnector'

Given /^a server prefix "([^"]*)"$/ do |server_prefix|
  @server_prefix = server_prefix
  @user_name = ENV['USER']
  @password = ENV['PASSWORD']
end

Given /^a server list of "([^"]*)"$/ do |server_names_string|
  @server_list = server_names_string.split(",")
end

When /^the server connect is performed$/ do
  connector = ProdDriveConnector.new
  @results = connector.connect_to_remote(@server_prefix, @server_list, @user_name.dup, @password.dup)
end

Then /^the status should be connected$/ do
  @results.each_pair do |server_name, connection_result|
    expect(connection_result).to eql(0)
  end
end

Given /^a connected server list of "([^"]*)"$/ do |server_names_string|
  connector = ProdDriveConnector.new
  @server_list = server_names_string.split(",")
  @conn_results = connector.connect_to_remote(@server_prefix, @server_list, @user_name.dup, @password.dup)
  ensure_all_results_zero(@conn_results)
end

When /^the server disconnect server is performed$/ do
  connector = ProdDriveConnector.new
  @results = connector.disconnect_from_remote(@server_prefix, @server_list)
end

Then /^the status should be disconnected$/ do
  @results.each_pair do |server_name, connection_result|
    expect(connection_result).to eql(0)
  end
end

def ensure_all_results_zero(results)
  results.each_pair do |server_name, connection_result|
    throw "Non Zero returncode! #{connection_result}" if connection_result == false
  end
end
