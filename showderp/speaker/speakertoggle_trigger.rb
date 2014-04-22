Trigger.new do |t|
  t.match { |info|
    info[:what] == '!stoggle' &&
    info[:where] == 'c'
  }

  t[:id] = "speakertoggle"
  
  t.act do |info|
    (info[:all][2][0] == '#' || info[:all][2][0] == '@') or next
    
    $speakable[info[:room]] && !(info[:respond].call("I will suppress my free speech")) || (info[:respond].call("I can now talk freely"))
    
    $speakable[info[:room]] = !$speakable[info[:room]]
  end
end
