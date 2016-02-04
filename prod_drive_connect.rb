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

ADD_CONNECTION = Win32API.new('mpr', 'WNetAddConnection2', 'PPPP', 'I')

# read user name/password from command line  domain/username password
USER_NAME = ARGV[0]
USER_PASSWORD = ARGV[1]

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

def connect_to_remote(server_prefix, server_list)
  server_list.each do |server_name|
    remote_name = "\\\\#{server_prefix}-#{server_name}.pointroll.local"
    netresource_struct = build_netresource(remote_name)
    return_value = ADD_CONNECTION.call(
      netresource_struct.pack('LLLLPPPP'),    # lpNetResource
      USER_PASSWORD, USER_NAME, nil                       # dwFlags
    )
    puts "connecting to #{remote_name} with return value: #{return_value}"
  end
end

def get_server_list(start_number, end_number)
  server_list = (start_number..end_number).collect { |item| "WEB#{item.to_s.rjust(2,"0")}"}
  server_list
end

server_list = get_server_list(6,29)
connect_to_remote("P-PR-ADS", server_list)

track_list = get_server_list(21, 40)
connect_to_remote("P-PR-TRK", track_list)

click_list = get_server_list(11, 14)
connect_to_remote("P-PR-CLK", click_list)

util_list = ["DS01", "AS01", "MS01", "WEB03", "WEB04"]
connect_to_remote("P-PR-UTL", util_list)

adp_list = ["BAT11", "DFA11", "WEB21", "WEB22", "WEB23", "WEB24"]
connect_to_remote("P-PR-ADP", adp_list)

onp_list = get_server_list(11, 14)
connect_to_remote("P-PR-ONP", onp_list)

ccb_list = get_server_list(11,12)
connect_to_remote("P-PR-CCB", ccb_list)

med_list = get_server_list(11,12)
connect_to_remote("P-PR-MED", med_list)

clt_list = get_server_list(11,18)
connect_to_remote("P-PR-CLT", clt_list)

vcon_list = get_server_list(11,12)
connect_to_remote("P-PR-VCON", vcon_list)
