# suck trigger - keeps track of how many times a user uses !suck
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
  

  dickspath = './triggers/suck/suck'
  t.act { |info|


    if info[:where] == "pm"
      info[:respond].call("This command must be done in public")
    end

    info[:where] == "c" or next
    
    numero = record_entry_suck(info[:who], info[:room], dickspath)
    info[:respond].call("#{info[:who]} has sucked #{numero} time(s)")

  }
end
