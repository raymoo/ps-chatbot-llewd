Trigger.new do |t|
  t[:id] = "topic"
  t[:cooldown] = 3 # seconds
  t[:lastused] = Time.now - t[:cooldown]
  
  t.match { |info|
    info[:what][0..5].downcase == '!topic'
  }
  
  t.act do |info|
    # ignores the cooldown check if user is PMing
    if info[:where] != 'pm'
      t[:lastused] + t[:cooldown] < Time.now or next
      t[:lastused] = Time.now
    end
    
    info[:respond].call("Nothing is the topic (not even SAO)")
  end
end
