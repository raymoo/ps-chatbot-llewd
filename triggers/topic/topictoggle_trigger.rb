# topic toggle trigger - allows toggling of voice permissions
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
  t[:id] = "topictoggle"
  
  t.match { |info|
    info[:what] == '.ttoggle' &&
    info[:where] == 'c'
  }

  
  t.act do |info|

    (info[:fullwho][0] =~ /[@#]/) or next

    $voiceperm && !(info[:respond].call("Voices may no longer change the topic")) || (info[:respond].call("Voices can now change the topic"))

    $voiceperm = !$voiceperm

  end
end
