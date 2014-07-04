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


require 'faye/websocket'
require 'eventmachine'
require 'em-http-request'
require 'json'
require 'fileutils'
require 'yaml'

require './app/chatbot.rb'
require './app/chathandler.rb'
require './app/battle.rb'
require './app/consoleinput.rb'
require './app/socketinput.rb'
require './app/utils.rb'







require './app/pokedata.rb'

if __FILE__ == $0
  
  cfg_file = ARGV[0]
  
  if cfg_file
    puts "Using config file: #{cfg_file}."
  else
    puts "No config file specified, attempting to use 'config.yml'"
    cfg_file = 'config.yml'
  end

  if File.exist?(cfg_file)
    configs = YAML.load(File.open(cfg_file))["bots"]
  else
    raise "config file specified #{cfg_file} does not exist!"
  end
  
  $0 = 'pschatbot'
  
  EM.run do
    bots = []
    configs.each do |options|
      bot = Chatbot.new(
        id: options['id'],
        name: options['name'], 
        pass: options['pass'],
        room: options['room'], # compatibility
        rooms: options['rooms'], 
        console: options['console'],
        server: (options['server'] || nil),
        log: options['log'],
        usetriggers: options['usetriggers'],
        triggers: options['triggers'],
        dobattles: options['dobattles'],
        
        allconfig: options)
      
      bots << bot
      
    end
    
    exiting = false
    exitblk = proc do
      
      next if exiting
      
      exiting = true
      
      bots.each do |bot|
        bot.exit_gracefully
      end
      
    end
    
    at_exit &exitblk
    
  end
  


end
