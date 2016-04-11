require "Win32API"

class ProdDriveConnector

  RESOURCETYPE_ANY = 0x3
  CONNECT_UPDATE_PROFILE    = 0x1
  RESOURCE_CONNECTED        = 0x1
  RESOURCE_GLOBALNET        = 0x2
  RESOURCETYPE_DISK         = 0x1
  RESOURCEDISPLAYTYPE_SHARE = 0x3
  RESOURCEUSAGE_CONNECTABLE = 0x1

  def disconnect_from_remote(server_prefix, server_list)
    remove_connection = Win32API.new('mpr', 'WNetCancelConnection2', 'PII', 'I')
    server_list.each do |server_name|
      remote_name = "\\\\#{server_prefix}-#{server_name}.pointroll.local"
      return_value = remove_connection.call(
          remote_name,              # remote name
          CONNECT_UPDATE_PROFILE,  # dwFlags
          1            # fForce always force it to close
      )
      puts "disconnect_from_remote #{remote_name} with return value: #{return_value}"
    end
  end

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

  def connect_to_remote(server_prefix, server_list, user_name, user_password)
    add_connection = Win32API.new('mpr', 'WNetAddConnection2', 'PPPP', 'I')
    server_list.each do |server_name|
      remote_name = "\\\\#{server_prefix}-#{server_name}.pointroll.local"
      netresource_struct = build_netresource(remote_name)
      return_value = add_connection.call(
        netresource_struct.pack('LLLLPPPP'),    # lpNetResource
        user_password, user_name, nil           # dwFlags
      )
      puts "connecting to #{remote_name} with return value: #{return_value}"
    end
  end

  def get_server_list(start_number, end_number)
    server_list = (start_number..end_number).collect { |item| "WEB#{item.to_s.rjust(2,"0")}"}
    server_list
  end

  def get_full_server_hash()
    server_hash = {}
    server_hash["P-PR-ADS"] = get_server_list(6,29)
    server_hash["P-PR-TRK"] = get_server_list(21, 40)
    server_hash["P-PR-CLK"] = get_server_list(11, 14)
    server_hash["P-PR-ONP"] = get_server_list(11, 14)
    server_hash["P-PR-CCB"] = get_server_list(11,12)
    server_hash["P-PR-MED"] = get_server_list(11,12)
    server_hash["P-PR-CLT"] = get_server_list(11,18)
    server_hash["P-PR-VCON"] = get_server_list(11,12)
    server_hash["P-PR-UTL"] = ["DS01", "AS01", "MS01", "WEB03", "WEB04"]
    server_hash["P-PR-ADP"] = ["BAT11", "DFA11", "WEB21", "WEB22", "WEB23", "WEB24"]
    server_hash
  end

end
