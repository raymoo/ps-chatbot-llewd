# jak_trigger.rb - prints text version of darkjak's trainer card
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
  t[:id] = "jak"
  t[:cooldown] = 5 # seconds
  t[:lastused] = Time.now - t[:cooldown]
  
  t.match { |info|
    info[:what][0..3].downcase == '.jak' &&
    (info[:where] == 'pm' || info[:room] == 'showderp')
  }
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next

    t[:lastused] = Time.now

    info[:respond].call('**DarkJak**')
    info[:respond].call('**Ace:** Mega Charizard-X')
    info[:respond].call('**Catchphrase:** The Darkside cannot be extinguished, when you fight')
  end
end
