require "./showderp/speaker/markovchains.rb"

Trigger.new do |t|
  t.match { |info|
    (info[:where] == 'c') && info[:what]
  }
  
  t[:id] = "speaker"
  t[:chain] = Markov::Chain.new
  $speakable = Hash.new
  $speakable.default = true
  
  t.act do |info|
    text = info[:result]
    
    name = $login[:name]
    
    if text[0..name.size-1] == name && text[name.size] == ','
      next if info[:who] == $login[:name] || !$speakable[info[:room]]
      (info[:all][2][0] == '#' || info[:all][2][0] == '@' || info[:all][2][0] == '%' || info[:all][2][0] == '+') or next
      words = text[name.size..-1].split(' ')
      seed = nil

      t[:chain].nodes.each do |keys, values|
        if words.any? { |word| keys.index(word) }
          seed = keys
          break
        end
      end
      
      info[:respond].call("#{info[:who]} #{t[:chain].generate(10, seed).join(' ')}.".capitalize)
    else
      t[:chain].add_words(text)
    end
  end
end
