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
  
  t[:id] = "wl"
  
  t.match { |info|
    info[:what] =~ /\A!wl ([^,]+)\z/ && $1
  }
  
  banlist_folder = './showderp/autoban/banlists/'
  
  t.act do |info|
    
    # First check if :who is a mod
    
    next unless info[:all][2][0] =~ /[@#]/
      
    # Form path to actual whitelist file

    banlist_path = banlist_folder + info[:room] + ".whitelist"

    # Add info[:result] to the white list
    
    if !File.exist?(banlist_path) then
      info[:respond].call("This room is not configured to use a whitelist")
      next
    end

    who = CBUtils.condense_name(info[:result])
    
    next if File.read(banlist_path).split("\n").index(who)
    
    File.open(banlist_path, "a") do |f|
      f.puts(who)
    end
    info[:respond].call("Added #{who} to whitelist.")
    
    
    
  end
end
