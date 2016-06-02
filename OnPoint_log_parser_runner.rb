
require './OnPointUserLogReader'

# ruby OnPoint_log_parser_runner.rb /home/tjanusz929/Documents/MyBooks/ONPTraffic3
parser = OnPointUserLogReader.new
parser.count_user_logins(ARGV[0])
