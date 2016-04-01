require './HistoricalReportFileParser'

# ruby HistoricalReportFileUtils.rb
# "C://temp//2016-03-25 14_48_42.3233Run.log"

parser = HistoricalReportFileParser.new
parser.process_directory(ARGV[0])
