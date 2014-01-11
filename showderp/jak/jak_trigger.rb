Trigger.new do |t|
  t[:id] = "jak"
  
  t.match { |info|
    info[:what][0..3].downcase == '!jak'
  }
  
  t.act do |info|
    info[:respond].call('**DarkJak**')
    info[:respond].call('**Ace:** Mega Charizard-X')
    info[:respond].call('**Catchphrase:** The Darkside cannot be extinguished, when you fight')
  end
end
