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

      it "adds new count value to existing array of values" do
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

    it "calculates time as end time minues start time" do
      actual_total_time = parser.get_total_time_in_minutes(line, next_line)
      expect(actual_total_time).to eql(3)
    end

    it "calculates time as 0 if missing start time" do
      line = ""
      actual_total_time = parser.get_total_time_in_minutes(line, next_line)
      expect(actual_total_time).to eql(0)
    end

    it "calculates time as 0 if missing end time" do
      next_line = ""
      actual_total_time = parser.get_total_time_in_minutes(line, next_line)
      expect(actual_total_time).to eql(0)
    end
  end

  describe "#calculate_total_count_of_values" do
    it "returns total count as sum of all value arrays" do
      time_hash = { 1 => [1,2], 2 => [1]}
      actual_total_count = parser.calculate_total_count_of_values(time_hash)
      expect(actual_total_count).to eql(3)
    end

    it "returns 0 for empty value arrays" do
      time_hash = {}
      actual_total_count = parser.calculate_total_count_of_values(time_hash)
      expect(actual_total_count).to eql(0)
    end

  end

end
