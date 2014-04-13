$voiceperm = true

Trigger.new do |t|
  t[:id] = "topic"
  t[:cooldown] = 3 # seconds
  t[:lastused] = Time.now - t[:cooldown]
  
  t.match { |info|
    info[:what][0..5].downcase == '!topic' &&
    info[:where] == 'c'
  }

  t[:topic] = Hash.new
  t[:topic].default = "Nothing (not even SAO)"
  
  t.act do |info|

    (info[:all][2][0] == '#' || info[:all][2][0] == '@' || info[:all][2][0] == '%' || info[:all][2][0] == '+') or next

    t[:lastused] + t[:cooldown] < Time.now or next
    t[:lastused] = Time.now
    
    if info[:what].size > 7 && ($voiceperm || !(info[:all][2][0] == '+'))
      t[:topic][info[:room]] = info[:what][7..-1]
    end

    info[:respond].call("/wall The topic is: " + t[:topic][info[:room]])
  end
end
