# ps-chatbot: a chatbot that responds to commands on Pokemon Showdown chat
# Copyright (C) 2014 pickdenis
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
  
  t[:id] = "unban"
  
  t.match { |info|
    info[:what] =~ /\A!(?:uab|aub) ([^,]+)\z/ && $1
  }
  
  banlist_folder = './triggers/autoban/banlists/'
  
  t.act do |info|
    
    # First check if :who is a mod
    
    next unless info[:all][2][0] =~ /[@#]/
    
    # Form path to actual banlist file

    banlist_path = banlist_folder + info[:room] + ".banlist"

    # Remove info[:result] from the ban list
    FileUtils.touch(banlist_path)
    who = info[:result]
    
    info[:respond].call("/roomunban #{who}")

    banlist = File.read(banlist_path).split("\n")
    banlist.delete(CBUtils.condense_name(who))
    
    File.open(banlist_path, "w") do |f|
      f.puts(banlist)
    end
    
    info[:respond].call("Removed #{who} from list.")

    
  end
end
