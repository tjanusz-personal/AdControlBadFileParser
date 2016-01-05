
require './AdControlReader'

# ruby AdControlBadFileParser.rb
# "C://temp//BadAdControlRecsLast7Days"
# "C://temp//BadAdControlRecsLast7Days(Ruby).csv"

parser = AdControlReader.new
parser.readAllAdControlLogs(ARGV[0], ARGV[1])
