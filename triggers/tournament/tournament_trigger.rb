# tournament trigger - provides for joining and playing in tournaments
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
  t[:id] = "tournament"
  
  t.match { |info|
    info[:where] == 'tournament'
  }

  
  t.act do |info|

    if info[:action] == 'create' && info[:all][3] == 'challengecup1vs1'
      info[:respond].call("/tour join")
    end
    
    if info[:action] == 'update'
      infos = JSON.parse(info[:all][3])

      if infos["challenged"]
        info[:respond].call("/tour acceptchallenge")
      end

      if infos["challenges"] && infos["challenges"].length != 0
        infos["challenges"].each{|challenge| info[:respond].call("/tour challenge #{challenge}")}
      end
      
    end
    
  end
end
