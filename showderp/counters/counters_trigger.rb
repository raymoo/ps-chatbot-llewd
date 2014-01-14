Trigger.new do |t|
  t[:lastused] = Time.now
  t[:cooldown] = 60 # seconds
  t[:sao] ||= 0
  # t[:naruto] ||= 0
  # t[:souleater]
  # t[:attackontitan]
  # t[:dragonball]
  # t[:deathnote]

  t.match { |info|
    # info[:what].scan(/\bnaruto\b/i))
    info[:print] = info[:where] == 'c' && info[:what][0] == '!' && info[:what].scan(/counter/i).any?
    counter = info[:where] == 'c' && info[:what].scan(/(\bSword\sArt\sOnline\b|\bSAO\b)/i).any? && info[:who].downcase != "gamecorner"
    
    info[:print] || counter
  }
  
  t.act { |info|
    t[:sao] += info[:what].scan(/(\bSword\sArt\sOnline\b|\bSAO\b)/i).length
    # t[:naruto] += info[:what].scan(/\bnaruto\b/i).length

    result = "SAO counter: #{t[:sao]}" # Naruto counter: #{info[:naruto]}. 
    puts result
    if info[:print] && t[:lastused] + t[:cooldown] < Time.now
      info[:respond].call(result)
      t[:lastused] = Time.now
    end
  }
end
