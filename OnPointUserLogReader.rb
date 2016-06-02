require 'csv'

class OnPointUserLogReader

  # group everything after userName=
  # group everything after password= till whitespace
  @@regex_user_name_password = /.*userName=(?<user_name>.+?)&password=(?<password>.+?)\s.*/

  # 01:12:23
  @@regex_time_stamp = /(?<time>\d\d:\d\d:\d\d)/

  # 2016-06-01
  @@regex_date_stamp = /(?<date>\d\d\d\d-\d\d-\d\d)/

  def addQuotesToLine(textLine)
    re = /^.*?$/
    textLine.gsub(re, '\'\0\'')
  end

  def self.regex_user_name_password
    @@regex_user_name_password
  end

  def self.regex_time_stamp
    @@regex_time_stamp
  end

  def self.regex_date_stamp
    @@regex_date_stamp
  end

  def user_login_line?(log_line)
    # sorry for not (not match) but other operator "=~" returns nil or fixnum
    !(log_line !~ %r{GET /services/User/Login})
  end

  def count_user_logins(directory_name)
    puts "Starting to read files"
    user_dictionary = process_files(directory_name)
    print_out_results(user_dictionary)
    puts "Done reading files"
  end

  def process_files(directory_name)
    user_dictionary = Hash.new(0)  # make sure values are zero'd out

    Dir.foreach(directory_name) do |file_name|
      next if file_name == '.' or file_name == '..'
      File.open(directory_name + "//" + file_name).each do |line|
        process_file_line(user_dictionary, line)
      end
    end
    user_dictionary
  end

  def process_file_line(user_dictionary, file_line)
    return unless user_login_line?(file_line)
    myMatch = OnPointUserLogReader.regex_user_name_password.match(file_line)
    user_name = myMatch[:user_name]
    user_dictionary[user_name] += 1
  end

  def print_out_results(user_dictionary)
    user_dictionary.each { |user, count| puts "#{user.ljust(50)} #{count}"}
  end

end
