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
    result = l + (h << 32)
    (result/1073741824.0).round(2)
end

def print_disk_sizes(server_prefix, server_list, c_min, d_min, include_d = true)
  server_list.each do |server_name|
    d_path = "\\\\#{server_prefix}-#{server_name}.pointroll.local\\D$"
    c_path = "\\\\#{server_prefix}-#{server_name}.pointroll.local\\C$"
    if include_d
      d_space = get_disk_free_space(d_path)
    else
      d_space = "N/A"
    end
    c_space = get_disk_free_space(c_path)
    if c_space < c_min
      c_space = "#{red(c_space)}"
    end

    if d_space != "N/A" and d_space < d_min
      d_space = "#{red(d_space)}"
    end

    puts "Server: #{server_prefix}-#{server_name} \t C: #{c_space} \t D: #{d_space}"
  end
end

def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

def red(text)
  colorize(text, 31)
end

# TODO: need to figure out how to make this dynamic
puts "### AD SERVERS \t\t C: 9 \t\t D: 100"
server_list = ["WEB06", "WEB07", "WEB08", "WEB09", "WEB10", "WEB11", "WEB12", "WEB13", "WEB14", "WEB15", "WEB16", "WEB17",
  "WEB18", "WEB19", "WEB20", "WEB21", "WEB22", "WEB23", "WEB24", "WEB25", "WEB26", "WEB27", "WEB28", "WEB29"]
print_disk_sizes("P-PR-ADS", server_list, 9, 100)

puts ""
puts "### TRACK SERVERS \t C: 8 \t\t D: 60"
track_list = ["WEB21", "WEB22", "WEB23", "WEB24", "WEB25", "WEB26", "WEB27", "WEB28", "WEB29", "WEB30", "WEB31", "WEB32",
  "WEB33", "WEB34", "WEB35", "WEB36", "WEB37", "WEB38", "WEB39", "WEB40"]
print_disk_sizes("P-PR-TRK", track_list, 8, 60)

puts ""
puts "### CLICK SERVERS \t C: 20 \t\t D: 49"
click_list = ["WEB11", "WEB12", "WEB13", "WEB14"]
print_disk_sizes("P-PR-CLK", click_list, 20, 49)

puts ""
puts "### UTL SERVERS \t C: 12 \t\t D:40"
util_list = ["DS01"]
print_disk_sizes("P-PR-UTL", util_list, 12, 40)

puts ""
puts "### ONP SERVERS \t C: 23 \t\t D: 40"
onp_list = ["WEB11", "WEB12", "WEB13", "WEB14"]
print_disk_sizes("P-PR-ONP", onp_list, 23, 40)

puts ""
puts "### ADP SERVERS \t C: 18"
adp_list = ["WEB21", "WEB22", "WEB23", "WEB24"]
print_disk_sizes("P-PR-ADP", adp_list, 18, 0, false)

puts ""
puts "### CCB SERVERS \t C: 25"
ccb_list = ["WEB11", "WEB12"]
print_disk_sizes("P-PR-CCB", ccb_list, 25, 0, false)
