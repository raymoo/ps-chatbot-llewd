# next post trigger - responds to "next post..." with a leak
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
  t[:id] = "npost"
  t[:cooldown] = 600 # seconds
  t[:lastused] = Time.now - t[:cooldown]
  
  t.match { |info|
    info[:what][0..8].downcase == 'next post' &&
    (info[:where] == 'pm' || info[:room] == 'showderp')
  }
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next
    
    t[:lastused] = Time.now

    info[:respond].call("**COME JOIN OUR SECRET CLUB:** /join showderp")
  end
end
