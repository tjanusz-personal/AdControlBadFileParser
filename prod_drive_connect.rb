require "Win32API"
require "./ProdDriveConnector"

## invoke this script to connect all the DC3 server resources
## ruby prod_drive_connect.rb "domain\username" "password"
## this must be invoked before running the prod_drive_size.rb file
# read user name/password from command line  domain/username password
USER_NAME = ARGV[0]
USER_PASSWORD = ARGV[1]

connector = ProdDriveConnector.new
server_hash = connector.get_full_server_hash()

server_hash.each_pair do |server_name, server_list|
  connector.connect_to_remote(server_name, server_list, USER_NAME, USER_PASSWORD)
end
