require "./HistoricalReportErrorLogParser"

## execute all specs using
## rspec . --format documentation

RSpec.describe HistoricalReportErrorLogParser do
  subject(:parser) { HistoricalReportErrorLogParser.new }

  describe "#get_line_type" do
    it "returns 'SP_ROW' with line containing 'Stored Procedure to Call'" do
      line = "2016-04-18 09:51:54.0493 -- Stored Procedure to Call: exec Run_Historical_Report @Defined_Historical_Reporting_Details_ID=45220"
      expect(parser.get_line_type(line)).to eql("SP_ROW")
    end
    it "returns 'TIMEOUT_ERROR' with line containing 'Timeout expired'" do
      line = "2016-04-18 11:04:53.0098 -- System.Data.SqlClient.SqlException (0x80131904): Timeout expired.  The timeout period"
      expect(parser.get_line_type(line)).to eql("TIMEOUT_ERROR")
    end
    it "returns 'COLUMN_ERROR' with line containing 'Invalid column name'" do
      line = "2016-04-18 05:53:43.5789 -- System.Data.SqlClient.SqlException (0x80131904): Invalid column name 'UPICBC_O'."
      expect(parser.get_line_type(line)).to eql("COLUMN_ERROR")
    end
    it "returns 'UNK' with line containing normal text" do
      line = "2016-04-18 05:52:58.5085 -- START"
      expect(parser.get_line_type(line)).to eql("UNK")
    end
    it "returns 'UNK' with nil" do
      expect(parser.get_line_type(nil)).to eql("UNK")
    end
  end

  describe "#process_file" do
    context "with file having Timeout expired error and column error" do
      it "adds error and timeout details rows to error_hash" do
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
        2016-03-30 16:39:40.6854 -- START
        2016-03-30 16:39:40.6854 -- Historical Detail Record to Run: 999
        2016-03-30 16:39:40.6854 -- Stored Procedure to Call: exec Run_Historical_Report @Defined_Historical_Reporting_Details_ID=999
        2016-03-30 16:39:40.6854 -- System.Data.SqlClient.SqlException (0x80131904): Invalid column name 'UPICBC_O'.
           at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
           at System.Data.SqlClient.SqlInternalConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)
        2016-03-30 16:39:41.2387 -- END
        )
        error_hash = { "COLUMN_ERROR" => [], "TIMEOUT_ERROR" => []}
        buffer = StringIO.new(dummy_file_contents)
        filename = "TestFile.log"
        allow(File).to receive(:open).with(filename, "r").and_yield(buffer)
        parser.process_file(filename, error_hash)
        expect(error_hash["TIMEOUT_ERROR"].first[:id]).to eql(811)
        expect(error_hash["COLUMN_ERROR"].first[:id]).to eql(999)
      end
    end

    context "with file having no errors" do
      it "does not add any errors to error_hash" do
        dummy_file_contents = %q(
        2016-03-30 16:38:18.3917 -- START
        2016-03-30 16:38:22.4479 -- Historical Detail Record to Run: 166
        2016-03-30 16:38:22.4479 -- Stored Procedure to Call: exec Run_Historical_Report @Defined_Historical_Reporting_Details_ID=166
        2016-03-30 16:38:33.9300 -- Writing File Name: Toyota_8337_Noun_by_Week_20150101_20150131.xlsx to Dest: Toyota
        2016-03-30 16:38:33.9300 -- Full Path: D:\Historical_Reports\Toyota\Toyota_8337_Noun_by_Week_20150101_20150131.xlsx
        2016-03-30 16:38:33.9300 -- Total rows for Tier is: 1
        2016-03-30 16:38:33.9300 -- Total rows for Client_Type is: 6793
        2016-03-30 16:38:36.8005 -- END
        2016-03-30 16:40:36.8161 -- START
        2016-03-30 16:40:36.8317 -- Historical Detail Record to Run: 223
        2016-03-30 16:40:36.8317 -- Stored Procedure to Call: exec Run_Historical_Report @Defined_Historical_Reporting_Details_ID=223
        2016-03-30 16:40:50.1391 -- Writing File Name: Toyota_8337_Conversions_by_Month_20150101_20150131.xlsx to Dest: Toyota
        2016-03-30 16:40:50.1391 -- Full Path: D:\Historical_Reports\Toyota\Toyota_8337_Conversions_by_Month_20150101_20150131.xlsx
        2016-03-30 16:40:50.1391 -- Total rows for Tier is: 1
        2016-03-30 16:40:50.1391 -- Total rows for Client_Type is: 1803
        2016-03-30 16:40:50.8256 -- END
        )
        error_hash = { "COLUMN_ERROR" => [], "TIMEOUT_ERROR" => []}
        buffer = StringIO.new(dummy_file_contents)
        filename = "TestFile.log"
        allow(File).to receive(:open).with(filename, "r").and_yield(buffer)
        parser.process_file(filename, error_hash)
        expect(error_hash["TIMEOUT_ERROR"]).to be_empty
        expect(error_hash["COLUMN_ERROR"]).to be_empty
      end
    end

  end

  describe "#get_report_details_id" do
    context "with valid line definition" do
      it "returns historical reporting details id number at end of line" do
        line = "2016-04-18 09:51:54.0493 -- Stored Procedure to Call: exec Run_Historical_Report @Defined_Historical_Reporting_Details_ID=45220"
        expect(parser.get_report_details_id(line)).to eql(45220)
      end
    end

    context "with invalid line definitions" do
      it "returns 0" do
        scenarios = ["2016-04-18 09:51:54.0493 -- Stored Procedure to Call: exec Run_Historical_Report @Defined_Historical_Reporting_Details_ID=",
          "2016-04-18 09:51:54.0493 -- Stored Procedure to Call: exec Run_Historical_Report @Defined_Historical_Reporting_Details_ID",
          "", "2016-04-18 09:51:54.0493 -- Stored Procedure"]
        scenarios.each do |scenario|
            expect(parser.get_report_details_id(scenario)).to eql(0)
        end
      end
    end
  end

  describe "#get_column_error" do
    it "returns the column name from the error log line" do
      line = "2016-03-30 16:39:40.6854 -- System.Data.SqlClient.SqlException (0x80131904): Invalid column name 'UPICBC_O'."
      expect(parser.get_column_error(line)).to eql(" 'UPICBC_O'.")
    end
    context "with no 'Invalid column name' text in log line" do
      it "returns full log line" do
        line = "2016-03-30 16:39:40.6854 -- System.Data.SqlClient.SqlException (0x80131904):"
        expect(parser.get_column_error(line)).to eql(line)
      end
    end
  end

  describe "#get_timeout_error" do
    it "returns initial log line information" do
      line = "2016-03-30 16:39:41.1450 -- System.Data.SqlClient.SqlException (0x80131904): Timeout expired.  The timeout period elapsed prior to completion of the operation or the server is not responding. ---> System.ComponentModel.Win32Exception (0x80004005): The wait operation timed out"
      expect(parser.get_timeout_error(line)).to eql("2016-03-30 16:39:41.1450 -- System.Data.SqlClient.SqlException (0x80131904): Timeout expired")
    end
    context "with no 'Timeout expired' text in log line" do
      it "returns full log line" do
        line = "2016-03-30 16:39:41.1450 -- System.Data.SqlClient.SqlException (0x80131904): "
        expect(parser.get_timeout_error(line)).to eql(line)
      end
    end
  end

end
