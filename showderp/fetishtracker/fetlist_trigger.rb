def count_stats(fetish, path)
  result = [0, 0, 0, 0, 0]
  path = path + '/' + fetish
  FileUtils.touch(path)
  entries = File.read(path).split("\n")

  entries.each {|entry|
    elements = entry.split(' ')
    result[Integer(elements[1])] += 1
  }

  result

end

Trigger.new do |t|
  t[:id] = "!fetlist"
  t[:nolog] = true
  
  t.match { |info|
    (info[:where].downcase == 'pm' || info[:where] == 's') &&
    info[:what].downcase == '!fetlist'
  }
  
  stats_path = './showderp/fetishtracker/stats'
  FileUtils.touch(stats_path)
  uploader = CBUtils::HasteUploader.new
  
  t.act do |info|
    
    stats = Dir.entries(stats_path)
    stats_text = "Fetish|0s|1s|2s|3s|4s\n"
    
    stats.each {|fetish|
      stats_text += fetish + "|" count_stats(fetish, stats_path).split("|") + "\n"
    }
  end
    
    uploader.upload(stats_text) do |url|
      info[:respond].call(url)
    end
    
  end
end
