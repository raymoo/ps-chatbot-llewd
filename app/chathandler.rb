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


require 'logger'
require 'json'

class ChatHandler
  attr_accessor :triggers, :ignorelist, :group, :usagelogger, :chatlogger
  attr_reader :id, :dirname, :name, :pass, :config
  
  def initialize triggers, chatbot
    @id = chatbot.id
    @name = chatbot.name
    @pass = chatbot.pass
    @config = chatbot.config
    
    @dirname = "bot-#{@id}"
    # initialize all of the directories that we need
    FileUtils.mkdir_p("./#{@dirname}/logs/chat")
    FileUtils.mkdir_p("./#{@dirname}/logs/usage")
    FileUtils.mkdir_p("./#{@dirname}/logs/pms")
    
    @trigger_files = triggers
    
    @triggers = []
    @ignorelist = []
    
    initialize_ignore_list
    
    # useless and redundant feature
    #initialize_usage_stats
    
    initialize_loggers
    
    initialize_message_queue
    
  end
  
  def initialize_ignore_list
    
    @ignore_path = "./#{@dirname}/ignored.txt"
    FileUtils.touch(@ignore_path)
    @ignorelist = IO.readlines(@ignore_path).map(&:chomp)
  end
  
  def initialize_loggers
    @usagelogger = Logger.new("./#{@dirname}/logs/usage/usage.log", 'monthly')
    @pmlogger = Logger.new("./#{@dirname}/logs/pms/pms.log", 'monthly')
    @pmlogger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime}: #{msg}\n"
    end
    @chatloggers = {} # add one for every new room

  end
  
  def initialize_usage_stats
    @usage_stats = {"c" => {}, "s" => {}, "pm" => {}}
    
    @usage_path = "./#{@dirname}/logs/usagestats.txt"
    
    FileUtils.touch(@usage_path)
    
    if File.zero?(@usage_path)
      File.open(@usage_path, "w") do |f|
        f.puts(JSON.dump(@usage_stats))
      end
    else
      File.open(@usage_path, "r") do |f|
        @usage_stats = JSON.parse(f.gets)
      end
    end
    
    
  end
  
  def print_usage_stats howmany
    "deprecated"
    #relevant_stats = @usage_stats['c'].to_a
    # 
    #buf =  "Top #{howmany} (ab)users: \n"
    # 
    #relevant_stats.sort! {|(x, y)| y.length }
    # 
    #buf << '  ' << relevant_stats.take(howmany).map { |(x, y)| [x, y.size] }.join("\t") << "\n"
    #buf
  end
  
  def initialize_message_queue
    @message_queue = EM::Queue.new
    
    timer = EM::PeriodicTimer.new(0.1) do
      @message_queue.pop do |msg|
        ws, msg = msg
        ws.send(msg)
      end
    end
  end
  
  def queue_message ws, msg
    throw "Message queue not initialized" if !@message_queue
    @message_queue.push([ws, msg])
  end
  
  def load_trigger_files
    
    files = @trigger_files
    
    Dir["./essentials/**/*_trigger.rb"].each do |f|
      load_trigger(f)
    end
    
    if files
      files.each do |f|
        load_trigger("./#{f}")
      end
    end
    
  end
  
  def load_trigger(file)
    puts "#{@id}: loading:  #{file}"
    
    ch = self # This is so that 'ch' can be accessed within the trigger
    trigger = eval(File.read(file))
    
    return unless trigger.is_a? Trigger
    
    trigger[:ch] = self
    trigger[:login_name] = @name
    
    trigger.init
    
    @triggers << trigger
  end
  
  def make_info message, ws
    info = {where: message[1], ws: ws, all: message, ch: self, id: @id}
    
    info.merge!(
      case info[:where].downcase
      when "c"
        {
          room: message[0][1..-2],
          who: message[2][1..-1],
          fullwho: message[2],
          what: message[3],
        }
      when 'j', 'l'
        {
          room: message[0][1..-2],
          who: message[2][1..-1],
          fullwho: message[2],
          what: ''
        }
      when 'n'
        {
          room: message[0][1..-2],
          who: message[2][1..-1],
          fullwho: message[2],
          oldname: message[3],
          what: ''
          
        }
      when 'users'
        {
          room: message[0][1..-2],
          who: '',
          what: message[2]
        }
      when 'pm'
        {
          what: message[4],
          to: message[3][1..-1],
          who: message[2][1..-1],
          fullwho: message[2]
        }
      when 's'
        {
          room: message[0],
          who: @name,
          what: message[2],
        }
      when 'tournament'
        {
          room: message[0][1...-1],
          action: message[2],
          who: "",
          what: ""
        }
      end)
    
    info
  end
  
  
  def handle message, ws, callback = nil
    
    m_info = self.make_info(message, ws)
    
    
    @ignorelist.map(&:downcase).index(m_info[:who].downcase) and return
    
    @triggers.each do |t|
      begin
        t[:off] and next
        result = t.is_match?(m_info)
        
        if result
          m_info[:result] = result
          
          m_info[:respond] = (callback || 
            case m_info[:where].downcase
            when 'c', 'j', 'n', 'l', 'tournament'
              proc do |mtext| queue_message(m_info[:ws], "#{m_info[:room]}|#{mtext}") end
            when 's'
              proc do |mtext| puts mtext end
            when 'pm'
              proc do |mtext| queue_message(m_info[:ws], "|/pm #{m_info[:who]},#{mtext}") end
            end)
          
          
          
          
          
          # log the action
          if t[:id] && !t[:nolog] # only log triggers with IDs
            @usagelogger.info("#{m_info[:who]} tripped trigger id:#{t[:id]}")
            
            # Add to the stats
            #usage_stats_here = @usage_stats[m_info[:where]]
            #
            #usage_stats_here[m_info[:who]] ||= []
            #usage_stats_here[m_info[:who]] << t[:id]
          end
          
          t.do_act(m_info)
          
        end
      rescue => e
        puts "Crashed in trigger #{t[:id]}"
        puts e.message
        puts e.backtrace
      end   
      
    end
    
    
    # Log any chat messages
    if m_info[:where] == 'c'
      logger = @chatloggers[m_info[:room]]
      if !logger
        logger = @chatloggers[m_info[:room]] = Logger.new("./#{@dirname}/logs/chat/#{m_info[:room]}.log", 'monthly')
        logger.formatter = proc do |severity, datetime, progname, msg|
          "#{datetime}: #{msg}\n"
        end
      end
      
      logger.info("#{m_info[:who]}: #{m_info[:what]}")
    end
    
    if m_info[:where] == 'pm'
      @pmlogger.info("#{m_info[:who]}: #{m_info[:what]}")
      
    end
  end
  
  def turn_by_id id, on
    @triggers.each do |t|
      if t[:id] == id
        t[:off] = !on
        return true
      end
    end
    
    false
  end
  
  def exit_gracefully
    # Write the usage stats to the file
    
    #File.open(@usage_path, 'w') do |f|
    #  f.puts(JSON.dump(@usage_stats))
    #end
    
    # Write ignore list to the file
    
    IO.write(@ignore_path, @ignorelist.join("\n"))
    
    puts "#{@id}: Calling triggers' exit sequences..."
    @triggers.each do |trigger|
      trigger.exit
    end
    
    puts "#{@id}: Done with exit sequence"
    
  end
  
  def << trigger
    @triggers.push(trigger)
    self
  end

end

class Trigger
  
  def initialize &blk
    @vars = {}
    yield self
  end
  
  def match &blk
    @match = blk
  end
  
  def act &blk
    @action = blk
  end
  
  # Optional trigger field
  # t.exit { what to do when chatbot exits }
  def exit &blk
    if block_given?
      @exit = blk
    else
      if @exit
        @exit.call
      end
    end
  end
  
  # Optional trigger field
  # t.exit { what to do when trigger is initialized }
  def init &blk
    if block_given?
      @init = blk
    else
      if @init
        @init.call
      end
    end
  end
  
  def is_match? m_info
    @match.call(m_info)
  end
  
  def do_act m_info
    @action.call(m_info)
  end
  
  def get var
    @vars[var]
  end
  
  def set var, to
    @vars[var] = to
  end
  
  
  alias_method :[], :get
  alias_method :[]=, :set
end

