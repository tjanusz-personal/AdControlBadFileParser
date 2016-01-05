require "./AdControlReader"

## execute all specs using
## rspec . --format documentation

RSpec.describe AdControlReader do
  subject(:reader) { AdControlReader.new }

  describe "#processFileLine" do
    context "when passed empty keyDictionary" do
      it "adds new value to keyDictionary with count of 1" do
        keyDictionary = Hash.new(0)
        fileLine = "100,200,300,400,500,600,700"
        expectedKey = "400, 600, 700"
        reader.processFileLine(keyDictionary, fileLine)
        expect(keyDictionary).to have_key(expectedKey)
        expect(keyDictionary[expectedKey]).to eql(1)
      end
    end

    context "when passed keyDictionary with existing key/values" do
      it "increases the key's value count by 1" do
        expectedKey = "400, 600, 700"
        keyDictionary = {expectedKey => 1}
        fileLine = "100,200,300,400,500,600,700"
        reader.processFileLine(keyDictionary, fileLine)
        expect(keyDictionary[expectedKey]).to eql(2)
      end
    end
  end

  describe "#buildKeyFromLine" do
    it "returns key comprised of fourth, sixth and seventh comma separated values" do
      fileLine = "100,200,300,400,500,600,700"
      expect(reader.buildKeyFromLine(fileLine)).to eql("400, 600, 700")
    end

    it "returns blank key for invalid comma separated string" do
      fileLine = "100,200,300"
      expect(reader.buildKeyFromLine(fileLine)).to eql(", , ")
    end
  end

  describe "#printOutResults" do

    it "writes dictionary to CSV file sorted by keys" do
      keyDictionary = {"500, 600, 700" => 2, "400, 600, 700" => 1}
      expectedCSVContents = '["CampaignId", "CreativeId", "PlacementId", "", "Total"]["400", " 600", " 700", "", 1]["500", " 600", " 700", "", 2]'
      stubbedCSV = StringIO.new("")
      expect(CSV).to receive(:open).and_yield(stubbedCSV)
      reader.printOutResults(keyDictionary,"filename")
      # should fill mock StringIO with all CSV contents
      expect(stubbedCSV.string).to eql(expectedCSVContents)
    end
  end

end
