
require 'csv'

# ruby AdControlBadFileParser.rb
# "C://temp//BadAdControlRecsLast7Days"
# "C://temp//BadAdControlRecsLast7Days(Ruby).csv"
def processFiles(folderDir, outputFileName)
  keyDictionary = Hash.new(0)  # make sure values are zero'd out

  Dir.foreach(folderDir) do |fileName|
    next if fileName == '.' or fileName == '..'
    File.open(folderDir + "//" + fileName).each do |line|
      id_array = line.split(",")
      # need only these keys from file (Campaign Id, Creative Id, Placement Id)
      lineKey = "#{id_array[3]}, #{id_array[5]}, #{id_array[6]}"
      # total unique instances found across all files
      keyDictionary[lineKey] += 1
    end
  end
  printOutResults(keyDictionary, outputFileName)
end

def printOutResults(theDictionary, fileName)
  CSV.open(fileName, "wb") do |csv|
    # add header row to CSV
    csv << ["CampaignId", "CreativeId", "PlacementId", "", "Total"]
    # sort by key to ensure campaignId are grouped
    theKeys = theDictionary.keys.sort
    theKeys.each do |key|
      data_array = key.split(",")
      data_array << "" << theDictionary[key]
      csv << data_array
     end
  end
end

puts "Starting to read files"
processFiles(ARGV[0], ARGV[1])
puts "Done reading files"
