def just_latin?(str)
  !!str.match(/^[a-zA-Z0-9_\-+ ]*$/)
end


Trigger.new do |t|

  t[:id] = 'shiritori'
  
  t.match { |info|
    # checks
    info[:where] == 'c' &&
    info[:what][0..4] == '!srtr' &&
    info[:what][5..-1].strip
  }
  
  players = Array.new
  used = Array.new
  current = 0
  game = false

  t.act { |info|
    
    args = info[:result].split(' ')
    if args.count < 1 then
      (players.count > 0 && playerlist = "" + players.join(', ') + ' **Current:**  ' + players[current]) || playerlist = 'None'
      (game && !info[:respond].call('Players: ' + playerlist)) || info[:respond].call('There is currently no game')
      next
    end
       
    if args[0] == 'start' && !game && (info[:all][2][0] == '#' || info[:all][2][0] == '@') then
      game = true
      info[:respond].call("A new game of shiritori is starting. Type '!srtr join' to join.")
      next
    end
    
    speaker =  CBUtils.condense_name(info[:who])
    
    if args[0] == 'join' && game then
      if players.index speaker then
        info[:respond].call("You are already in the game")
      else
        players.push(speaker)
        (players.count > 0 && playerlist = "" + players.join(', ') + ' **Current:**  ' + players[current]) || playerlist = 'None'
        info[:respond].call('Players: ' + playerlist)
      end
      next
    end
    
    if args[0] == 'leave' && game then
      speakindex = players.index speaker
      if speakindex then
        players.index speaker && players.delete(speaker)
        if speakindex == current && current != 0 then current %= 0 end
        if speakindex < current then current -= 1 end

        (players.count > 0 && playerlist = "" + players.join(', ') + ' **Current:**  ' + players[current]) || playerlist = 'None'
        info[:respond].call('Players: ' + playerlist)
      else
        info[:respond].call("You're not in the game.")
      end
      next
    end
    
    if args[0] == 'end' && game && (info[:all][2][0] == '#' || info[:all][2][0] == '@') then
      game = false
      players = Array.new
      used = Array.new
      current = 0
      info[:respond].call("Game Ended.")
      next
    end
    
    if args[0] == 'play' && game then
      prevword = used[-1]
      if !(players.index speaker) then
        info[:respond].call("You are not in the game.")
      elsif players[current] != speaker
        info[:respond].call("It is not your turn.")
      elsif args.count < 2 || !just_latin?(args[1]) then
        info[:respond].call("Please use a single latin-alphabet word")
      elsif prevword && args[1].downcase[0] != prevword[-1]
        info[:respond].call("That word doesn't fit. The previous word was #{prevword}.")
      elsif used.index args[1].downcase
        info[:respond].call("That word has been used")
      else
        used.push(args[1].downcase)
        current = (current + 1) % players.count
        prevword = used[-1]
        info[:respond].call("#{players[current]}, your letter is **#{prevword[-1]}**.")
      end
      
      next
    end
     

  }
end
