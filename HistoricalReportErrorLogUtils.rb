require './HistoricalReportErrorLogParser'

# ruby HistoricalReportErrorLogUtils.rb
# "C://temp//HistoricalReportErrors"
parser = HistoricalReportErrorLogParser.new
parser.process_directory(ARGV[0])
