
class HistoricalReportErrorLogParser

  def process_directory(folderDir)
    error_hash = { "COLUMN_ERROR" => [], "TIMEOUT_ERROR" => []}
    Dir.foreach(folderDir) do |fileName|
      next if fileName == '.' or fileName == '..'
      process_file(folderDir + "\\" + fileName, error_hash)
    end
    print_error_hash(error_hash)
  end

  def process_file(fullFileName, error_hash)
    File.open(fullFileName, "r") do |file|
      while !file.eof?
        line = file.readline
        line_type = get_line_type(line)
        next unless line_type == "SP_ROW"
        next if file.eof?
        next_line = file.readline
        next_line_type = get_line_type(next_line)
        if next_line_type == "COLUMN_ERROR"
          error_hash["COLUMN_ERROR"] << { id: get_report_details_id(line), line: get_column_error(next_line)}
        elsif next_line_type == "TIMEOUT_ERROR"
          error_hash["TIMEOUT_ERROR"] << { id: get_report_details_id(line), line: get_timeout_error(next_line)}
        end
      end
    end
  end

  def print_error_hash(error_hash)
    puts "COLUMN ERROR TOTAL: #{error_hash["COLUMN_ERROR"].length}"
    error_hash["COLUMN_ERROR"].each { |line| puts line}
    puts "TIMEOUT ERROR TOTAL: #{error_hash["TIMEOUT_ERROR"].length}"
    error_hash["TIMEOUT_ERROR"].each { |line| puts line}
  end

  def get_line_type(line)
    return "UNK" if line.nil?
    return "SP_ROW" if line.include?("Stored Procedure to Call")
    return "COLUMN_ERROR" if line.include?("Invalid column name")
    return "TIMEOUT_ERROR" if line.include?("Timeout expired")
    return "UNK"
  end

  def get_report_details_id(line)
    string_parts = line.partition("@Defined_Historical_Reporting_Details_ID=")
    return string_parts[2].to_i
  end

  def get_column_error(error_line)
    return error_line unless error_line.include?("Invalid column name")
    string_parts = error_line.partition("Invalid column name")
    return string_parts[2]
  end

  def get_timeout_error(error_line)
    return error_line unless error_line.include?("Timeout expired")
    string_parts = error_line.partition("Timeout expired")
    return error_line if string_parts.size < 2
    return string_parts.first + string_parts[1]
  end

end
