require './ProdDriveSize'

Given /^the server prefix "([^"]*)"$/ do |arg1|
  @server_prefix = arg1
end

When /^the servers (\d+) through (\d+) disk spaces are checked$/ do |start_server_num, end_server_num|
  sizer = ProdDriveSize.new
  @output = sizer.get_disk_sizes(@server_prefix, start_server_num, end_server_num)
end

When /^the servers (\d+) through (\d+) C drives disk space checked$/ do |start_server_num, end_server_num|
  sizer = ProdDriveSize.new
  @output = sizer.get_disk_sizes(@server_prefix, start_server_num, end_server_num, false)
end

When /^the servers disk space checked:$/ do |table|
  rows = table.raw.flatten
  server_list = rows
  sizer = ProdDriveSize.new
  @output = sizer.query_disk_sizes(@server_prefix, server_list)
end

When /^the servers disk space checked include "([^"]*)"$/ do |comma_sep_string|
  server_list = comma_sep_string.split(",")
  sizer = ProdDriveSize.new
  @output = sizer.query_disk_sizes(@server_prefix, server_list)
end

When /^the servers C drive disk space checked include "([^"]*)"$/ do |comma_sep_string|
  server_list = comma_sep_string.split(",")
  sizer = ProdDriveSize.new
  @output = sizer.query_disk_sizes(@server_prefix, server_list, false)
end

Then /^the C Drive should have at least (\d+) GB$/ do |c_drive_size|
  error_hash = collect_errors(@output, c_drive_size, 0)
  expect(error_hash).to be_empty
end

And /^the D Drive should have at least (\d+) GB$/ do |d_drive_size|
  error_hash = collect_errors(@output, d_drive_size, 1)
  expect(error_hash).to be_empty
end

def collect_errors(drive_hash, expected_drive_size, index)
  errors_hash = drive_hash.select { |key, values| values[index].to_i < expected_drive_size.to_i}
  errors_hash.keys
end
