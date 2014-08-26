# fetstat trigger - displays statistics for one fetish
# Copyright (C) 2014 raymoo
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

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
  t[:cooldown] = 5 # seconds

  t.match { |info|
    # checks
    info[:what][0..7] == '!fetstat' &&
    info[:what][8..-1].strip
  }
  
  fetishstatspath = "./#{ch.dirname}/fetish/stats"

  FileUtils.mkdir_p(fetishstatspath)

  t.act { |info|
    # if those checks pass
    args = info[:result].split(' ')

    FileUtils.touch("./#{ch.dirname}/fetish/list")

    fetishes = File.read("./#{ch.dirname}/fetish/list").split(' ')
    info[:where] == "pm" or (info[:where] == "c" and t[:lastused] + t[:cooldown] < Time.now and t[:lastused] = Time.now) or next
    
    
    if info[:where] == 'c' && !(info[:fullwho][1] =~ /[%@#]/)
      info[:respond].call('To broadcast the full results of this command in a room you must be a driver or higher. Try pming')
      next
    end 

    if args.count < 1 || args[0] == "help" || args[0] == 
"info"
      result = 'Type "!fetstat <fetishid>" to view stats for a fetish. Available fetish ids are: '
      result += fetishes.join(', ')
      info[:respond].call(result)
      next
    end

    if !fetishes.include?(args[0])
      info[:respond].call("#{args[0]} is not a valid id. Type !fetstat for a list.")
      next
    end
    
    info[:respond].call("POLITICAL FORECAST FOR: #{args[0]}")

    results = count_stats(args[0], fetishstatspath)
    result = "#{results[0]} want it banned, #{results[1]} are okay with it as long as the links have warnings, #{results[2]} are okay with unlabelled links, #{results[3]} are okay with images with it being declared, and #{results[4]} love it."
    info[:respond].call(result)
  }
end
