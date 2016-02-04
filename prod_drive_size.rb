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

def print_disk_sizes(title, server_prefix, server_list, c_min, d_min, include_d = true)
  puts ""
  puts "### #{title} \t\t C: #{c_min} \t\t D: #{d_min}"
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

def get_server_list(start_number, end_number)
  server_list = (start_number..end_number).collect { |item| "WEB#{item.to_s.rjust(2,"0")}"}
  server_list
end

server_list = get_server_list(6,29)
print_disk_sizes("AD SERVERS", "P-PR-ADS", server_list, 9, 100)

track_list = get_server_list(21, 40)
print_disk_sizes("TRACK", "P-PR-TRK", track_list, 8, 60)

click_list = get_server_list(11, 14)
print_disk_sizes("CLICK", "P-PR-CLK", click_list, 20, 49)

util_list = ["DS01", "AS01", "MS01", "WEB03", "WEB04"]
print_disk_sizes("UTL", "P-PR-UTL", util_list, 9, 20)

onp_list = get_server_list(11, 14)
print_disk_sizes("ONP", "P-PR-ONP", onp_list, 23, 40)

adp_list = ["BAT11", "DFA11", "WEB21", "WEB22", "WEB23", "WEB24"]
print_disk_sizes("ADP", "P-PR-ADP", adp_list, 18, 0, false)

ccb_list = get_server_list(11,12)
print_disk_sizes("CCB", "P-PR-CCB", ccb_list, 25, 0, false)

med_list = get_server_list(11,12)
print_disk_sizes("MED", "P-PR-MED", med_list, 12, 10)

clt_list = get_server_list(11, 18)
print_disk_sizes("CLT", "P-PR-CLT", clt_list, 20, 0, false)

vcon_list = get_server_list(11, 12)
print_disk_sizes("VCON SERVERS", "P-PR-VCON", vcon_list, 15, 0, false)
