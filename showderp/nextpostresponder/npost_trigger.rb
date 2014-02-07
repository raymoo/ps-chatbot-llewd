
Trigger.new do |t|
  t[:id] = "npost"
  t[:cooldown] = 600 # seconds
  t[:lastused] = Time.now - t[:cooldown]
  
  t.match { |info|
    info[:what][0..8].downcase == 'next post' &&
    (info[:where] == 'pm' || info[:room] == 'showderp')
  }
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next
    
    t[:lastused] = Time.now

    info[:respond].call("**COME JOIN OUR SECRET CLUB:** /join showderp")
  end
end
