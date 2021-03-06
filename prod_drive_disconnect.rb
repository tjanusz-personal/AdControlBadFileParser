require "Win32API"
require "./ProdDriveConnector"

## invoke this script to disconnect all the DC3 server resources
## ruby prod_drive_disconnect.rb
## this must be run if the open connections are hung (e.g. reset password, etc.)

connector = ProdDriveConnector.new
server_hash = connector.get_full_server_hash()
server_hash.each_pair do |server_name, server_list|
  results = connector.disconnect_from_remote(server_name, server_list)
  results.each_pair {|remote_name, return_value| puts "disconnect from remote #{remote_name} with return value: #{return_value}"}
end
