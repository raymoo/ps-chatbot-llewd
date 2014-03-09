Trigger.new do |t|
  t[:id] = 'mess'
  t[:cooldown] = 20
  t[:lastused] = Hash.new
  t[:lastused].default = Time.now - t[:cooldown]


  t.match { |info|
    # checks
    info[:where] == 'pm' &&
    info[:what][0..4] == '!mess' &&
    info[:what][5..-1].strip
  }
  
  t.act { |info|
    t[:lastused][CBUtils.condense_name(info[:who])] + t[:cooldown] < Time.now or next

    t[:lastused][CBUtils.condense_name(info[:who])] = Time.now


    # gets arguments
    args = info[:result].split(', ')

    if args.count < 2
      info[:respond].call("You need to specify a destination and message")
    else
      # is it a room
      if args[0][0] == '#' && args[0].size > 1
        result = args[0][1..-1] + '|'
      else
        # placeholder until I figure out things
        result = '|/pm ' + args[0] + ', '
      end

      result += 'Anonymous Message: ' + args[1..-1].join(", ")
    end

    #sends message
    info[:ws].send(result)
  }
end
