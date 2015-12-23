
require 'csv'

# ruby AdControlBadFileParser.rb
# "C://temp//BadAdControlRecsLast7Days"
# "C://temp//BadAdControlRecsLast7Days(Ruby).csv"
def processFiles(folderDir, outputFileName)
  keyDictionary = Hash.new(0)

  Dir.foreach(folderDir) do |item|
    next if item == '.' or item == '..'
    File.open(folderDir + "//" + item).each do |line|
      strings = line.split(",")
      keys = "#{strings[3]}, #{strings[5]}, #{strings[6]}"
      keyDictionary[keys] += 1
    end
  end
  printOutResults(keyDictionary, outputFileName)
end

def printOutResults(theDictionary, fileName)
  CSV.open(fileName, "wb") do |csv|
    csv << ["CampId", "CreativeId", "PlacementId", "", "Total"]
    theKeys = theDictionary.keys.sort
    theKeys.each do |key|
      split_key = key.split(",")
      split_key << ""
      split_key << theDictionary[key]
      csv << split_key
     end
  end
end

puts "Starting to read files"
processFiles(ARGV[0], ARGV[1])
puts "Done reading files"
