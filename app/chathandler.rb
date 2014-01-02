require 'logger'
require 'json'

class ChatHandler
  attr_accessor :triggers, :ignorelist, :group, :usagelogger
  
  def initialize group
    @triggers = []
    @ignorelist = []
    @group = group
    
    initialize_ignore_list
    
    initialize_usage_stats
    
    initialize_loggers
    
    initialize_message_queue
    
  end
  
  def initialize_ignore_list
    @ignore_path = "./#{@group}/ignored.txt"
    FileUtils.touch(@ignore_path)
    @ignorelist = IO.readlines(@ignore_path).map(&:chomp)
  end
  
  def initialize_loggers
    
    @usagelogger = Logger.new("./#{@group}/logs/usage.log", 'daily')
  end
  
  def initialize_usage_stats
    @usage_stats = {"c" => {}, "s" => {}, "pm" => {}}
    
    @usage_path = "./#{@group}/logs/usagestats.txt"
    
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
    relevant_stats = @usage_stats['c'].to_a
    
    buf =  "Top #{howmany} (ab)users: \n"
    
    relevant_stats.sort! {|(x, y)| y.length }
    
    buf << '  ' << relevant_stats.take(howmany).map { |(x, y)| [x, y.size] }.join("\t") << "\n"
    buf
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
    
    files = IO.readlines("./#{@group}/triggers").map(&:chomp)
    
    if files
      files.each do |f|
        puts "loading:  ./#{@group}/#{f}"
        @triggers << eval(File.read("./#{@group}/#{f}"))
      end
    end
    
  end
  
  def make_info message, ws
    info = {where: message[1], ws: ws, all: message, ch: self}
    info.merge!(
      case info[:where].downcase
      when "c"
        {
          room: message[0][1..-2],
          who: message[2][1..-1],
          what: message[3],
        }
      when 'j', 'n', 'l'
        {
          room: message[0][1..-2],
          who: message[2][1..-1].chomp,
          what: ""
        }
      when 'pm'
        {
          what: message[4],
          to: message[3][1..-1],
          who: message[2][1..-1],
        }
      when 's'
        {
          room: message[0],
          who: $login[:name],
          what: message[2],
        }
      end)
    
    info
  end
  
  
  def handle message, ws, callback = nil
    m_info = self.make_info(message, ws)
    @ignorelist.map(&:downcase).index(m_info[:who].downcase) and return
    
    @triggers.each do |t|
      t[:off] and next
      result = t.is_match?(m_info)
      
      if result
        m_info[:result] = result
        
        m_info[:respond] = (callback || 
          case m_info[:where].downcase
          when 'c', 'j', 'n', 'l'
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
          usage_stats_here = @usage_stats[m_info[:where]]
          
          usage_stats_here[m_info[:who]] ||= []
          usage_stats_here[m_info[:who]] << t[:id]
        end
        
        t.do_act(m_info)
        
      end
      
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
    
    File.open(@usage_path, 'w') do |f|
      f.puts(JSON.dump(@usage_stats))
    end
    
    # Write ignore list to the file
    
    IO.write(@ignore_path, @ignorelist.join("\n"))
    
    puts "Done with exit sequence"
    
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

