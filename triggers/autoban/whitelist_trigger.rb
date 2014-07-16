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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.


Trigger.new do |t|
  t[:id] = "whitelist"
  t[:nolog] = true
  
  t.match { |info|
    info[:where].downcase =~ /\A[jnl]\z/
  }
  
  whitelist_folder = './triggers/autoban/banlists/'
  
  t.act do |info|
    
    whitelist_path = whitelist_folder + info[:room] + ".whitelist"

    next if !File.exist?(whitelist_path)

    whitelist = File.read(whitelist_path).split("\n")
    messages = Array.new(info[:all])
    
    while messages.size > 0
      if messages.shift.downcase == 'j'
        name = CBUtils.condense_name(messages.shift[1..-1]) # The first character will be ' ' or '+' etc
        if !whitelist.index(name) then
          info[:respond].call("/roomban #{name}")
          
        else
          info[:respond].call("/roomvoice #{name}") unless info[:all][2][0] == '%' || info[:all][2][0] == '@' || info[:all][2][0] == '#'
        end
      end
    end
  end
end
