require "Win32API"

## invoke this script to connect all the DC3 server resources
## ruby prod_drive_connect.rb "domain\username" "password"
## this must be invoked before running the prod_drive_size.rb file

RESOURCETYPE_ANY = 0x3
CONNECT_UPDATE_PROFILE    = 0x1
RESOURCE_CONNECTED        = 0x1
RESOURCE_GLOBALNET        = 0x2
RESOURCETYPE_DISK         = 0x1
RESOURCEDISPLAYTYPE_SHARE = 0x3
RESOURCEUSAGE_CONNECTABLE = 0x1

add_connection = Win32API.new('mpr', 'WNetAddConnection2', 'PPPP', 'I')

# read user name/password from command line  domain/username password
user_name = ARGV[0]
user_password = ARGV[1]

def build_netresource(remote_name)
  netresource_struct = [
    RESOURCE_GLOBALNET,         # dwScope
    RESOURCETYPE_DISK,          # dwType
    RESOURCEDISPLAYTYPE_SHARE,  # dwDisplayType
    RESOURCEUSAGE_CONNECTABLE,  # dwUsage
    nil,                        # lpLocalName
    remote_name,                # lpRemoteName
    nil,                        # lpComment
    nil,                        # lpProvider
  ]
  netresource_struct
end

# TODO: figure out how to make this dynamic
server_list = ["WEB06", "WEB07", "WEB08", "WEB09", "WEB10", "WEB11", "WEB12", "WEB13", "WEB14", "WEB15", "WEB16", "WEB17",
  "WEB18", "WEB19", "WEB20", "WEB21", "WEB22", "WEB23", "WEB24", "WEB25", "WEB26", "WEB27", "WEB28", "WEB29"]
server_list.each do |server_name|
  remote_name = "\\\\P-PR-ADS-#{server_name}.pointroll.local"
  netresource_struct = build_netresource(remote_name)
  return_value = add_connection.call(
    netresource_struct.pack('LLLLPPPP'),    # lpNetResource
    user_password, user_name, nil                       # dwFlags
  )
  puts "connecting to #{remote_name} with return value: #{return_value}"
end