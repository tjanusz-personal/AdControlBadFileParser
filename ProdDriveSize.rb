require "Win32API"

class ProdDriveSize

  def get_disk_free_space(path)
    getDiskFreeSpaceEx = Win32API.new("kernel32", "GetDiskFreeSpaceEx",['p','p','p','p'], 'i')

    free_caller = " " * 8
    total = " " * 8
    free = " " * 8
    result = getDiskFreeSpaceEx.call(path, free_caller, total, free)
    if result == 0
      getLastError = Win32API.new("kernel32", "GetLastError",['v'], "i")
      error_code = getLastError.call()
      error_message = "Call #{path} Failed with error: #{error_code}"
      raise error_message
    end
    l,h = free_caller.unpack("II")
    result = l + (h << 32)
    (result/1073741824.0).round(2)
  end

  def get_server_list(start_number, end_number)
    server_list = (start_number..end_number).collect { |item| "WEB#{item.to_s.rjust(2,"0")}"}
    server_list
  end

  def get_disk_sizes(server_type, start_number, end_number, include_d = true)
    server_list = get_server_list(start_number,end_number)
    results = query_disk_sizes(server_type, server_list, include_d)
    results
  end

  def query_disk_sizes(server_prefix, server_list, include_d = true)
    results = {}
    server_list.each do |server_name|
      full_server_name = "\\\\#{server_prefix}-#{server_name}.pointroll.local"
      d_path = "#{full_server_name}\\D$"
      c_path = "#{full_server_name}\\C$"
      if include_d
        d_space = get_disk_free_space(d_path)
      else
        d_space = "N/A"
      end
      c_space = get_disk_free_space(c_path)

      results[full_server_name] = []
      results[full_server_name] << c_space
      results[full_server_name] << d_space
    end
    results
  end

  def colorize(text, color_code)
    "\e[#{color_code}m#{text}\e[0m"
  end

  def red(text)
    colorize(text, 31)
  end

  def print_disk_sizes(title, server_results, c_min, d_min)
    puts ""
    puts "### #{title.ljust(37)} C: #{c_min.to_s.ljust(6)} D: #{d_min.to_s.ljust(6)}"
    server_results.each_pair do |server_name, values|
      c_space = values[0]
      d_space = values[1]
      if c_space < c_min
        c_space = "#{red(c_space)}"
      end

      if d_space != "N/A" and d_space < d_min
        d_space = "#{red(d_space)}"
      end
      puts "Server: #{server_name.ljust(33)} C: #{c_space.to_s.ljust(6)} D: #{d_space.to_s.ljust(6)}"
    end
  end

end
