require "./OnPointUserLogReader"

## execute all specs using
## rspec . --format documentation

RSpec.describe OnPointUserLogReader do
  subject(:reader) { OnPointUserLogReader.new }
  let(:log_line) { 'u_ex160601: 2016-06-01 01:04:25 GET /services/User/Login userName=worthman&password=test 80 - 200 0 0 374'}

  describe "#addQuotesToLine" do
      it "adds quotes to line using regex" do
        res = reader.addQuotesToLine("worthman@pointroll.com testPass")
        expect(res).to eql("'worthman@pointroll.com testPass'")
      end
  end

  describe "#Random RegEx Tests on LogFiles" do
    it "returns the UserName= to end of log line" do
      myMatch = /userName=/.match(log_line).post_match
      expect(myMatch).to eql("worthman&password=test 80 - 200 0 0 374")
    end

    it "returns the start of log line until year" do
      myMatch = /2016-06-01/.match(log_line).pre_match
      expect(myMatch).to eql("u_ex160601: ")
    end

  end

  describe "#regex_user_name_password" do
    it "returns user_name and password in match object" do
      myMatch = OnPointUserLogReader.regex_user_name_password.match(log_line)
      expect(myMatch[:user_name]).to eql("worthman")
      expect(myMatch[:password]).to eql("test")
    end
  end

  describe "#regex_time_stamp" do
    it "returns time portion of log line" do
      myMatch = OnPointUserLogReader.regex_time_stamp.match(log_line)
      expect(myMatch[:time]).to eql("01:04:25")
    end

    it "returns log line upto time stamp" do
      myMatch = OnPointUserLogReader.regex_time_stamp.match(log_line).pre_match
      expect(myMatch).to eql("u_ex160601: 2016-06-01 ")
    end
  end

  describe "#regex_date_stamp" do
    it "returns date portion of log line" do
      myMatch = OnPointUserLogReader.regex_date_stamp.match(log_line)
      expect(myMatch[:date]).to eql("2016-06-01")
    end
  end

  describe "#user_login_line?" do
    it "returns true with log line containing 'GET /services/User/Login'" do
      expect(reader.user_login_line?(log_line)).to eql(true)
    end

    it "returns false with log line missing 'GET /services/User/Login'" do
      non_login_line = 'GET user/test/detail'
      expect(reader.user_login_line?(non_login_line)).to eql(false)
    end

  end

  describe "#process_file_line" do
    let(:user_dictionary) { Hash.new(0) }

    context "when passed a valid user logon line" do
      it "adds the userName and count to the user_dictionary" do
        reader.process_file_line(user_dictionary, log_line)
        expect(user_dictionary["worthman"]).to eql(1)
      end

      it "increments the count on existing users in the user_dictionary" do
        user_dictionary["worthman"] = 3
        reader.process_file_line(user_dictionary, log_line)
        expect(user_dictionary["worthman"]).to eql(4)
      end

    end

    context "when passed a missing user logon line" do
      it "does not modify the user_dictionary" do
        line = ""
        reader.process_file_line(user_dictionary, line)
        expect(user_dictionary).to be_empty
      end
    end

  end

end
