# speaker toggle trigger - toggles bot's speech
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

Trigger.new do |t|
  t.match { |info|
    info[:what] == '!stoggle' &&
    info[:where] == 'c'
  }

  t[:id] = "speakertoggle"
  
  t.act do |info|
    (info[:fullwho][1] =~ /[@#]/) or next
    
    $speakable[info[:room]] && !(info[:respond].call("I will suppress my free speech")) || (info[:respond].call("I can now talk freely"))
    
    $speakable[info[:room]] = !$speakable[info[:room]]
  end
end
