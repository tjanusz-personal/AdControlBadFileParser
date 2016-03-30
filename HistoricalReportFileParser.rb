require 'date'
require 'set'

class HistoricalReportFileParser

  def process_file_two(fullFileName)
    time_hash = {}

    File.open(fullFileName, "r") do |file|
      while !file.eof?
        line = file.readline
        next unless cares_about_file_line?(line)
        next unless get_line_type(line) == "RowTotal"
        start_time = parse_line_stamp(line)
        next_line = file.readline
        end_time  = parse_line_stamp(next_line)
        row_count = parse_row_count(line)
        total_time_in_minutes = ( (end_time - start_time) * 24 * 60).to_i

        time_hash[total_time_in_minutes] = [] unless time_hash.key?(total_time_in_minutes)
        time_hash[total_time_in_minutes] << row_count
      end
    end
    print_time_hash(time_hash)
  end

  def print_time_hash(time_hash)
    total_count_of_values = 0
    time_hash.each do |key, value_array|
      total_count_of_values += value_array.size
    end

    puts "Total values is: #{format_number_with_commas(total_count_of_values)}"
    pct_of_total = 0.0
    time_hash.sort.map do |time_in_minutes, value_array|
      max_value_string = format_number_with_commas(get_max_value(value_array))
      total_values_for_time = value_array.size
      total_values_string = format_number_with_commas(total_values_for_time)
      pct_of_total = (total_values_for_time.to_f / total_count_of_values.to_f) * 100
      puts "XLSX Write Time in Minutes: #{time_in_minutes} \t MaxRowCount: #{max_value_string} \t\t Count: #{total_values_string} \t %: #{pct_of_total.round(3)}"
    end
  end

  def format_number_with_commas(the_number)
    the_number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end

  def get_max_value(the_set)
    max_value = 0
    the_set.each do |set_value|
      max_value = set_value.to_i unless max_value > set_value.to_i
    end
    max_value
  end

  def cares_about_file_line?(line)
    return true if line.include?("Total rows for Client_Type")
    return true if line.include?("END")
    return false
  end

  def get_line_type(line)
    return "RowTotal" if line.include?("Total rows for Client_Type")
    return "END" if line.include?("END")
    return "UNK"
  end

  def parse_line_stamp(line)
    str_array = line.split(" ")
    time_string = str_array[0] + " " + str_array[1]
    return DateTime.parse(time_string)
  end

  def parse_row_count(line)
    str_array = line.split(" ")
    str_array[8]
  end

end
