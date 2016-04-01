require 'date'
require 'set'

class HistoricalReportFileParser

  def process_directory(folderDir)
    time_hash = {}
    Dir.foreach(folderDir) do |fileName|
      next if fileName == '.' or fileName == '..'
      process_file(folderDir + "\\" + fileName, time_hash)
    end
    print_time_hash(time_hash)
  end

  def process_file(fullFileName, time_hash)
    File.open(fullFileName, "r") do |file|
      while !file.eof?
        line = file.readline
        next unless cares_about_file_line?(line)
        next unless get_line_type(line) == "RowTotal"
        next_line = file.readline
        row_count = parse_row_count(line)
        total_time_in_minutes = get_total_time_in_minutes(line, next_line)
        update_time_hash(time_hash, total_time_in_minutes, row_count)
      end
    end
  end

  def update_time_hash(time_hash, total_time_in_minutes, row_count)
    time_hash[total_time_in_minutes] = [] unless time_hash.key?(total_time_in_minutes)
    time_hash[total_time_in_minutes] << row_count
  end

  def get_total_time_in_minutes(line, next_line)
    start_time = parse_line_stamp(line)
    return 0 if start_time == nil
    end_time  = parse_line_stamp(next_line)
    return 0 if end_time == nil
    total_time_in_minutes = ( (end_time - start_time) * 24 * 60).to_i
    total_time_in_minutes
  end

  def calculate_total_count_of_values(time_hash)
    total_count_of_values = 0
    time_hash.each do |key, value_array|
      total_count_of_values += value_array.size
    end
    total_count_of_values
  end

  def print_time_hash(time_hash)
    total_count_of_values = calculate_total_count_of_values(time_hash)
    puts "Total values is: #{format_number_with_commas(total_count_of_values)}"

    pct_of_total = 0.0
    time_hash.sort.map do |time_in_minutes, value_array|
      avg_value_string = format_number_with_commas(avg_count_value(value_array))
      total_values_for_time = value_array.size
      total_values_string = format_number_with_commas(total_values_for_time)
      pct_of_total = (total_values_for_time.to_f / total_count_of_values.to_f) * 100
      puts "XLSX Write Time in Minutes: #{time_in_minutes.to_s.rjust(3)} AvgRowCount: #{avg_value_string.rjust(10)}  Count: #{total_values_string.rjust(6)}  #{pct_of_total.round(3).to_s.rjust(6)} %"
    end
  end

  def format_number_with_commas(the_number)
    the_number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end

  def avg_count_value(the_array_of_values)
    return nil if the_array_of_values.nil? or the_array_of_values.empty?
    sum_of_values = 0
    the_array_of_values.each { |a_value| sum_of_values += a_value }
    return sum_of_values / the_array_of_values.size
  end

  def cares_about_file_line?(line)
    return true if line.include?("Total rows for Client_Type")
    return true if line.include?("END")
    return false
  end

  def get_line_type(line)
    return "UNK" if line.nil?
    return "RowTotal" if line.include?("Total rows for Client_Type")
    return "END" if line.include?("END")
    return "UNK"
  end

  def parse_line_stamp(line)
    return nil if line.nil?
    str_array = line.split(" ")
    return nil if str_array.empty? or str_array.size < 2
    time_string = str_array[0] + " " + str_array[1]
    return DateTime.parse(time_string)
  end

  def parse_row_count(line)
    return 0 if line.nil?
    str_array = line.split(" ")
    str_array[8].to_i
  end

end
