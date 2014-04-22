Trigger.new do |t|
  t[:id] = "tournament"
  
  t.match { |info|
    info[:where] == 'tournament'
  }

  
  t.act do |info|

    if info[:action] == 'create' && info[:all][3] == 'challengecup1vs1'
      info[:respond].call("/tour join")
    end
    
    if info[:action] == 'update'
      infos = JSON.parse(info[:all][3])

      if infos["challenged"]
        info[:respond].call("/tour acceptchallenge")
      end

      if infos["challenges"] && infos["challenges"].length != 0
        info[:respond].call("/tour challenge #{infos["challenges"][0]}")
      end
      
    end
    
  end
end
