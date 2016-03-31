require "./HistoricalReportFileParser"

## execute all specs using
## rspec . --format documentation

RSpec.describe HistoricalReportFileParser do
  subject(:parser) { HistoricalReportFileParser.new }

  describe "#update_time_hash" do
    context "when hash missing time key" do
      it "adds time as key and initialzes values to array with count as first value" do
        time_hash = {}
        parser.update_time_hash(time_hash, 1, 300)
        expect(time_hash).to have_key(1)
        expect(time_hash[1]).to eql([300])
      end
    end

    context "when hash has existing time key entry" do
      it "adds new count value to array of values" do
        time_hash = { 1 => [300]}
        parser.update_time_hash(time_hash, 1, 500)
        expect(time_hash).to have_key(1)
        expect(time_hash[1]).to eql([300, 500])
      end

      it "adds duplicate count value if value already in array" do
        time_hash = { 1 => [300]}
        parser.update_time_hash(time_hash, 1, 300)
        expect(time_hash).to have_key(1)
        expect(time_hash[1]).to eql([300, 300])
      end
    end
  end

  describe "#get_total_time_in_minutes" do
    let(:line) { "2016-03-28 21:45:08.7122 -- Total rows for Client_Type is: 1611159" }
    let(:next_line) { "2016-03-28 21:48:09.0086 -- END" }

    context "with valid start and end times in log lines" do
      it "calculates time as end time minues start time" do
        actual_total_time = parser.get_total_time_in_minutes(line, next_line)
        expect(actual_total_time).to eql(3)
      end
    end
    context "with missing start time" do
      it "calculates time as 0" do
        line = ""
        actual_total_time = parser.get_total_time_in_minutes(line, next_line)
        expect(actual_total_time).to eql(0)
      end
    end

    context "with missing end time" do
      it "calculates time as 0" do
        next_line = ""
        actual_total_time = parser.get_total_time_in_minutes(line, next_line)
        expect(actual_total_time).to eql(0)
      end
    end
  end

  describe "#calculate_total_count_of_values" do
    context "with valid array of values" do
      it "returns total count as sum of all value arrays" do
        time_hash = { 1 => [1,2], 2 => [1]}
        actual_total_count = parser.calculate_total_count_of_values(time_hash)
        expect(actual_total_count).to eql(3)
      end
    end
    context "with empty array of values" do
      it "returns 0" do
        time_hash = {}
        actual_total_count = parser.calculate_total_count_of_values(time_hash)
        expect(actual_total_count).to eql(0)
      end
    end
  end

  describe "#format_number_with_commas" do
    context "with valid number" do
      it "returns comma separated values for thousands, millions, etc" do
        [ [1000, "1,000"], [1000000, "1,000,000"], [100, "100"]].each do |scenario_array|
          number_string = parser.format_number_with_commas(scenario_array[0])
          expect(number_string).to eql(scenario_array[1])
        end
      end
    end
  end

  describe "#get_max_value" do
    context "with valid array of integer values" do
      it "returns maximum value" do
        values = [ 100, 200, 1, 600, 1]
        max_number = parser.get_max_value(values)
        expect(max_number).to eql(600)
      end
    end
    context "with empty array" do
      it "returns nil" do
        max_number = parser.get_max_value([])
        expect(max_number).to be nil
      end
    end
  end

  describe "#cares_about_file_line" do
    context "with line containing 'Total Rows for Client'" do
      it "returns true" do
        client_type_line = "2016-03-28 21:45:08.7122 -- Total rows for Client_Type is: 1611159"
        expect(parser.cares_about_file_line?(client_type_line)).to be true
      end
    end
    context "with line containg 'END'" do
      it "returns true" do
        end_type_line = "2016-03-28 21:48:09.0086 -- END"
        expect(parser.cares_about_file_line?(end_type_line)).to be true
      end
    end
    context "with line containing other values" do
      it "returns false" do
        ["HELLO WORLD", ""].each do |scenario|
          expect(parser.cares_about_file_line?(scenario)).to be false
        end
      end
    end
  end

  describe "#get_line_type" do
    context "with line containing 'Total rows for Client_Type'" do
      it "returns 'RowTotal'" do
        client_type_line = "2016-03-28 21:45:08.7122 -- Total rows for Client_Type is: 1611159"
        expect(parser.get_line_type(client_type_line)).to eql("RowTotal")
      end
    end
    context "with line containing 'END'" do
      it "returns 'END'" do
        end_type_line = "2016-03-28 21:48:09.0086 -- END"
        expect(parser.get_line_type(end_type_line)).to eql("END")
      end
    end
    context "with line containing other values" do
      it "returns 'UNK'" do
        ["Hello world line", "", nil].each do |scenario|
          expect(parser.get_line_type(scenario)).to eql("UNK")
        end
      end
    end
  end

  describe "#parse_line_stamp" do
    context "with line containing valid date time information" do
      it "returns DateTime element from log line" do
          client_type_line = "2016-03-28 21:45:08.7122 -- Total rows for Client_Type is: 1611159"
          expectedDateTime = DateTime.parse("2016-03-28 21:45:08.7122")
          actualDateTime = parser.parse_line_stamp(client_type_line)
          expect(actualDateTime).to eql(expectedDateTime)
      end
    end
    context "with line missing valid date time information" do
      it "returns nil" do
        ["2016-03-28", "", nil].each do |scenario|
          actualDateTime = parser.parse_line_stamp(scenario)
          expect(actualDateTime).to be nil
        end
      end
    end
  end

  describe "#parse_row_count" do
    context "with log line having 'Total rows for Client_Type'" do
      it "returns row count value as integer from log line" do
          client_type_line = "2016-03-28 21:45:08.7122 -- Total rows for Client_Type is: 1611159"
          row_count = parser.parse_row_count(client_type_line)
          expect(row_count).to eql(1611159)
      end
    end
    context "with log line missing 'Total rows for Client_Type'" do
      it "returns 0" do
        ["", nil].each do |scenario|
          row_count = parser.parse_row_count(scenario)
          expect(row_count).to eql(0)
        end
      end
    end
  end

  describe "#print_time_hash" do
    context "given time has with valid hash values" do
      it "prints out 'Total values' and Row summaries for each line of time_hash" do
        $stdout = StringIO.new
        time_hash = { 1 => [200, 300], 2 => [100]}
        parser.print_time_hash(time_hash)
        $stdout.rewind
        expect($stdout.gets.strip).to eql("Total values is: 3")
        expect($stdout.gets.strip).to eql("XLSX Write Time in Minutes: 1 \t MaxRowCount: 300 \t\t Count: 2 \t %: 66.667")
        expect($stdout.gets.strip).to eql("XLSX Write Time in Minutes: 2 \t MaxRowCount: 100 \t\t Count: 1 \t %: 33.333")
        expect($stdout.gets).to be nil
      end
    end
    context "given empty time hash" do
      it "prints out 'Total values is: 0' and nothing else" do
        $stdout = StringIO.new
        parser.print_time_hash({})
        $stdout.rewind
        expect($stdout.gets.strip).to eql("Total values is: 0")
        expect($stdout.gets).to be nil
      end
    end
  end

  describe "#process_file" do
    context "when passed valid file" do
      it "processes file contents and writes output to console window" do
        dummy_file_contents = %q(
        2016-03-30 16:38:18.3917 -- START
        2016-03-30 16:38:22.4479 -- Historical Detail Record to Run: 166
        2016-03-30 16:38:22.4479 -- Stored Procedure to Call: exec Run_Historical_Report @Defined_Historical_Reporting_Details_ID=166
        2016-03-30 16:38:33.9300 -- Writing File Name: Toyota_8337_Noun_by_Week_20150101_20150131.xlsx to Dest: Toyota
        2016-03-30 16:38:33.9300 -- Full Path: D:\Historical_Reports\Toyota\Toyota_8337_Noun_by_Week_20150101_20150131.xlsx
        2016-03-30 16:38:33.9300 -- Total rows for Tier is: 1
        2016-03-30 16:38:33.9300 -- Total rows for Client_Type is: 6793
        2016-03-30 16:38:36.8005 -- END
        2016-03-30 16:39:40.6854 -- START
        2016-03-30 16:39:40.6854 -- Historical Detail Record to Run: 811
        2016-03-30 16:39:40.6854 -- Stored Procedure to Call: exec Run_Historical_Report @Defined_Historical_Reporting_Details_ID=811
        2016-03-30 16:39:41.1450 -- System.Data.SqlClient.SqlException (0x80131904): Timeout expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out
           at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
           at HistoricalReportingProcessor.HistoricalReportProcessor.runHistoricalReportRequest() in c:\_PointRoll\historicalreporting\HistoricalReportingProcessor\HistoricalReportProcessor.cs:line 54
        ClientConnectionId:588c6cd4-7d47-4726-a867-6051c07c22af
        Error Number:-2,State:0,Class:11
        2016-03-30 16:39:41.2387 -- END
        2016-03-30 16:40:36.8161 -- START
        2016-03-30 16:40:36.8317 -- Historical Detail Record to Run: 223
        2016-03-30 16:40:36.8317 -- Stored Procedure to Call: exec Run_Historical_Report @Defined_Historical_Reporting_Details_ID=223
        2016-03-30 16:40:50.1391 -- Writing File Name: Toyota_8337_Conversions_by_Month_20150101_20150131.xlsx to Dest: Toyota
        2016-03-30 16:40:50.1391 -- Full Path: D:\Historical_Reports\Toyota\Toyota_8337_Conversions_by_Month_20150101_20150131.xlsx
        2016-03-30 16:40:50.1391 -- Total rows for Tier is: 1
        2016-03-30 16:40:50.1391 -- Total rows for Client_Type is: 1803
        2016-03-30 16:40:50.8256 -- END
          )

        buffer = StringIO.new(dummy_file_contents)
        filename = "TestFile.log"
        allow(File).to receive(:open).with(filename, "r").and_yield(buffer)
        $stdout = StringIO.new
        parser.process_file(filename)
        $stdout.rewind
        expect($stdout.gets.strip).to eql("Total values is: 2")
        expect($stdout.gets.strip).to eql("XLSX Write Time in Minutes: 0 \t MaxRowCount: 6,793 \t\t Count: 2 \t %: 100.0")
      end
    end

    context "when passed valid empty file" do
      it "processes file contents and only writes Total Values line in console window" do
        buffer = StringIO.new("")
        filename = "TestFile.log"
        allow(File).to receive(:open).with(filename, "r").and_yield(buffer)
        $stdout = StringIO.new
        parser.process_file(filename)
        $stdout.rewind
        expect($stdout.gets.strip).to eql("Total values is: 0")
        expect($stdout.gets).to be nil
      end
    end

    context "when passed invalid file name" do
      it "raises SystemCallError" do
        expect { parser.process_file("TestJunk.log") }.to raise_error(SystemCallError)
      end
    end

  end

end
