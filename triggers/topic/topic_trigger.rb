# topic trigger - Allows the setting and displaying of a topic
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

$voiceperm = true

Trigger.new do |t|
  t[:id] = "topic"
  t[:cooldown] = 3 # seconds
  t[:lastused] = Time.now - t[:cooldown]
  
  t.match { |info|
    info[:what][0..5].downcase == '!topic' &&
    info[:where] == 'c'
  }

  t[:topic] = Hash.new
  t[:topic].default = "Nothing (not even SAO)"
  
  t.act do |info|

    (info[:fullwho][0] =~ /[+%@#]/) or next

    t[:lastused] + t[:cooldown] < Time.now or next
    t[:lastused] = Time.now
    
    if info[:what].size > 7 && ($voiceperm || !(info[:fullwho][0] == '+'))
      t[:topic][info[:room]] = info[:what][7..-1]
    end

    info[:respond].call("/wall The topic is: " + t[:topic][info[:room]])
  end
end
