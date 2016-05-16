require './HistoricalReportFileParser'

# ruby HistoricalReportFileUtils.rb
# "C://temp//HistoricalReportLogs"

parser = HistoricalReportFileParser.new
parser.process_directory(ARGV[0])
