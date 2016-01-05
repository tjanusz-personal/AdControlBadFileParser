require 'csv'

class AdControlReader

  def readAllAdControlLogs(folderDir, outputFileName)
    puts "Starting to read files"
    keyDictionary = processFiles(folderDir)
    printOutResults(keyDictionary, outputFileName)
    puts "Done reading files"
  end

  def processFileLine(keyDictionary, fileLine)
    # total unique instances found across all files
    keyDictionary[buildKeyFromLine(fileLine)] += 1
  end

  def buildKeyFromLine(fileLine)
    id_array = fileLine.split(",")
    # need only these keys from file (Campaign Id, Creative Id, Placement Id)
    lineKey = "#{id_array[3]}, #{id_array[5]}, #{id_array[6]}"
    lineKey
  end

  def processFiles(folderDir)
    keyDictionary = Hash.new(0)  # make sure values are zero'd out

    Dir.foreach(folderDir) do |fileName|
      next if fileName == '.' or fileName == '..'
      File.open(folderDir + "//" + fileName).each do |line|
        processFileLine(keyDictionary, line)
      end
    end
    keyDictionary
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

end
