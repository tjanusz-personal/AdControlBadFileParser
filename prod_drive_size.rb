require "Win32API"

## invoke this script to list out the current hard disk sizes for all the ad servers in prod
## You must invoke the prod_drive_connect.rb file first to connect the network resources

GetDiskFreeSpaceEx = Win32API.new("kernel32", "GetDiskFreeSpaceEx",['p','p','p','p'], 'i')
GetLastError = Win32API.new("kernel32", "GetLastError",['v'], "i")

def get_disk_free_space(path)
    free_caller = " " * 8
    total = " " * 8
    free = " " * 8
    result = GetDiskFreeSpaceEx.call(path, free_caller, total, free)
    if result == 0
      puts "Call Failed with error: #{GetLastError.call()}"
      return 0
    end
    l,h = free_caller.unpack("II")
    l + (h << 32)
end

# TODO: need to figure out how to make this dynamic
server_list = ["WEB06", "WEB07", "WEB08", "WEB09", "WEB10", "WEB11", "WEB12", "WEB13", "WEB14", "WEB15", "WEB16", "WEB17",
  "WEB18", "WEB19", "WEB20", "WEB21", "WEB22", "WEB23", "WEB24", "WEB25", "WEB26", "WEB27", "WEB28", "WEB29"]
server_list.each do |server_name|
  path = "\\\\P-PR-ADS-#{server_name}.pointroll.local\\D$"
  puts "Server: #{path} free space: #{(get_disk_free_space(path)/1073741824.0).round(2)} GB"
end
