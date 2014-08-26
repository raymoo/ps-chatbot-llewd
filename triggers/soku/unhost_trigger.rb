Trigger.new do |t|
  t[:id] = "unhost"
  
  t.match { |info|
    info[:what][0..6].downcase == '!unhost' 
  }
  
  t.act do |info|

    (info[:fullwho][1] =~ /[+%@#]/) or next

    hoster = CBUtils.condense_name(info[:who])
    hostinfo = $hosters[hoster]

    if hostinfo
      info[:respond].call($hosters.delete(hoster)[:hoster] + " is no longer hosting")
    else
      info[:respond].call("You are not hosting")
    end

  end
end
