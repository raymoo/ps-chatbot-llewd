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


require "./triggers/bread/breadfinder.rb"
require "./triggers/bread/battles.rb"

Trigger.new do |t| # battles
  t[:id] = 'afd'
  t[:cooldown] = 10 # seconds
  t[:lastused] = Time.now - t[:cooldown]
  
  t.match { |info| 
    info[:what].downcase == '.afd' &&
    (info[:where] == 'pm' || info[:room] == 'showderp')
    
  }
  
  t.act do |info|
    t[:lastused] + t[:cooldown] < Time.now or next
    
    t[:lastused] = Time.now
    
    Battles.get_battles do |battles|
      battle, time = battles.last
      
      
      result = if battle.nil?
        "couldn't find any battles, sorry"
      else
        time_since = (Time.now - time).to_i / 60 # minutes
        
        battle["play.pokemonshowdown.com"] = "showdown-afd.psim.us"
        "champ battle: #{battle}, posted #{time_since} minutes ago."
      end
      
      info[:respond].call(result)
    end
  end
end
