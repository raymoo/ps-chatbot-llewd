Trigger.new do |t|
  t[:id] = "topictoggle"
  
  t.match { |info|
    info[:what] == '!ttoggle' &&
    info[:where] == 'c'
  }

  
  t.act do |info|

    (info[:all][2][0] == '#' || info[:all][2][0] == '@') or next

    $voiceperm && !(info[:respond].call("Voices may no longer change the topic")) || (info[:respond].call("Voices can now change the topic"))

    $voiceperm = !$voiceperm

  end
end
