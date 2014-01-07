def count_stats(fetish, path)
  result = [0, 0, 0, 0, 0]
  path = path + '/' + fetish
  FileUtils.touch(path)
  entries = File.read(path).split("\n")

  entries.each {|entry|
    elements = entry.split(' ')
    result[Integer(elements[1])] += 1
  }

  result

end

Trigger.new do |t|
  t[:id] = 'fetstat'
  t[:lastused] = Time.now
  t[:cooldown] = 10 # seconds

  t.match { |info|
    # checks
    info[:what][0..7] == '!fetstat'
  }
  
  fetishstatspath = './showderp/fetishtracker/stats'
  fetishes = File.read('./showderp/fetishtracker/list').split(' ')

  t.act { |info|
    # if those checks pass
    
    if info[:where] == 'c' && !(info[:all][2][0] == '#' || info[:all][2][0] == '@' || info[:all][2][0] == '%' || info[:all][2][0] == '+')
      info[:respond].call('To broadcast the full results of this command in a room you must be a voice or higher.')
      next
    end 

    
    info[:respond].call('TODAY\'S POLITICAL FORECAST')

    fetishes.each{|fetish|
      results = count_stats(fetish, fetishstatspath)
      result = "#{fetish}: #{results[0]} want it banned, #{results[1]} are okay with it as long as the links have warnings, #{results[2]} are okay with unlabelled links, #{results[3]} are okay with images with it being declared, and #{results[4]} love it."
      info[:respond].call(result)
    }

  }
end
