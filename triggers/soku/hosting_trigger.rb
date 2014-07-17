Trigger.new do |t|
  t[:id] = "hosting"
  
  t.match { |info|
    info[:what][0..7].downcase == '!hosting' 
  }
  
  t.act do |info|

    if $hosters.length == 0
      message = "Nobody is hosting"
      queue_message(info[:ws], "|/pm #{info[:who]}, #{message}")
    else
      $hosters.each_value{|value|
        message = value[:hoster] + " at " + value[:address] + " " + (Time.now - value[:time]).round.to_s + " seconds ago"
        queue_message(info[:ws], "|/pm #{info[:who]}, #{message}")
      }
    end

  end
end
