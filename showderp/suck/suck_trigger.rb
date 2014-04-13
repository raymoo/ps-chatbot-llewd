def is_num?(str)
  begin
    !!Integer(str)
  rescue ArgumentError, TypeError
    false
  end
end

def record_entry_suck(user, room, path)
  user = CBUtils.condense_name(user)
  index = nil
  num = nil
  path = path + '/' + room
  FileUtils.touch(path)
  entries = File.read(path).split("\n")
  


  entries.each_with_index {|entry, i|
    elements = entry.split(' ')
    if elements[0] == user
      index = i
      num = Integer(elements[1]) + 1
      break
    end
  }


  if index == nil
    newentry = user + ' ' + 1.to_s + "\n"
    num = 1
    File.open(path, "a") do |f|
      f.puts(newentry)
    end

  else
    newentry = user + ' ' + num.to_s
    entries[index] = newentry
    result = entries.join("\n")
    File.open(path, "w") do |f|
      f.puts(result)
    end
  end
  return num
end

Trigger.new do |t|

  t[:id] = 'suck'
  t[:lastused] = Time.now
  t[:cooldown] = 5 # seconds
  
  t.match { |info|
    # checks
    info[:what][0..6] == '!suck'
  }
  

  dickspath = './showderp/suck/suck'
  t.act { |info|


    if info[:where] == "pm"
      info[:respond].call("This command must be done in public")
    end

    info[:where] == "c" or next
    
    numero = record_entry_suck(info[:who], info[:room], dickspath)
    info[:respond].call("#{info[:who]} has sucked #{numero} time(s)")

  }
end
