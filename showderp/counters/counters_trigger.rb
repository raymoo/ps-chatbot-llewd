Trigger.new do |t|
  t[:lastused] = Time.now
  # t[:cooldown] = 3 # seconds
  t[:saocounter] ||= 0

  t.match { |info|
    # puts "#{info[:where]}, #{info[:who]}, #{info[:what]}"

    info[:where] == 'c' &&
    info[:what].scan(/\bsao\b/i).any? &&
    info[:who].downcase != "gamecorner"
    # info[:what].scan(/\bnaruto\b/i))
  }
  
  t.act { |info|
    # t[:lastused] + t[:cooldown] < Time.now or next
    # t[:lastused] = Time.now
    t[:saocounter] += info[:what].scan(/\bsao\b/i).length
    # info[:narutocounter] ||= 0
    # info[:narutocounter] += info[:what].scan(/\bnaruto\b/i).length

    result = "SAO counter: #{t[:saocounter].to_s}" # Naruto counter: #{info[:narutocounter]}. 
    puts result
    info[:respond].call(result)
  }
end
