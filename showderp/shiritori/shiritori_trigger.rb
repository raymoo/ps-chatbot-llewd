Trigger.new do |t|

  t[:id] = 'shiritori'
  
  t.match { |info|
    # checks
    info[:where] == 'c' &&
    info[:what][0..4] == '!srtr' &&
    info[:what][5..-1].strip
  }
  
  t[:players] = Array.new
  t[:used] = Array.new
  t[:current] = 0
  game = false

  t.act { |info|
    
    args = info[:result].split(' ')
    if args.count < 1 then
      (t[:players].count > 0 && playerlist = "" + t[:players].join(', ') + ' **Current:**  ' + t[:players][t[:current]]) || playerlist = 'None'
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
      if t[:players].index speaker then
        info[:respond].call("You are already in the game")
      else
        t[:players].push(speaker)
        (t[:players].count > 0 && playerlist = "" + t[:players].join(', ') + ' **Current:**  ' + t[:players][t[:current]]) || playerlist = 'None'
        info[:respond].call('Players' + playerlist)
      end
      next
    end
    
    if args[0] == 'leave' && game then
      speakindex = t[:players].index speaker
      if speakindex then
        t[:players].index speaker && t[:players].delete(speaker)
        (t[:players].count > 0 && playerlist = "" + t[:players].join(', ') + ' **Current:**  ' + t[:players][t[:current]]) || playerlist = 'None'
        info[:respond].call('Players' + playerlist)
        speakindex <= t[:current] && t[:current] != 0 && t[:current]-= 1
      else
        info[:respond].call("You're not in the game.")
      end
      next
    end
    
    if args[0] == 'end' && game && (info[:all][2][0] == '#' || info[:all][2][0] == '@') then
      game = false
      t[:players] = Array.new
      t[:used] = Array.new
      t[:current] = 0
      info[:respond].call("Game Ended.")
      next
    end
    
  }
end
