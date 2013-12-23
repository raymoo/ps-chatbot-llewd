require 'readline'

class Console
  attr_accessor :ws, :ch
  
  def initialize ws, ch
    @ws = ws
    @ch = ch
    
    @handler_triggers = [Trigger.new do |t|
      t[:id] = 'console_exit'
      t[:nolog] = true
      
      t.match { |info|
        info[:where] == 's' &&
        info[:what] == 'exit'
      }
      
      t.act { |info|
        info[:respond].call('exiting console...')
        end_thread
      }
    end, Trigger.new do |t|
      t[:id] = 'console_toff'
      t[:nolog] = true
      
      t.match { |info| 
        info[:where] == 's' &&
        info[:what][0..3] == "toff" &&
        info[:what][5..-1]
      }
      
      t.act { |info| 
        if @ch.turn_by_id(info[:result], false)
          info[:respond].call("Turned off trigger: #{info[:result]}")
        else
          info[:respond].call("No such trigger: #{info[:result]}")
        end
      }
    end, Trigger.new do |t|
      t[:id] = 'console_ton'
      t[:nolog] = true
      
      t.match { |info| 
        info[:where] == 's' &&
        info[:what][0..2] == "ton" &&
        info[:what][4..-1]
      }
      
      t.act { |info| 
        if @ch.turn_by_id(info[:result], true)
          info[:respond].call("Turned on trigger: #{info[:result]}")
        else
          info[:respond].call("No such trigger: #{info[:result]}")
        end
      }
    end, Trigger.new do |t|
      t[:id] = 'console_ignore'
      t[:nolog] = true
      
      t.match { |info| 
        info[:where] == 's' &&
        info[:what][0..5] == "ignore" &&
        info[:what][7..-1]
      }
      
      t.act { |info| 
        realname = CBUtils.condense_name(info[:result])
        
        if @ch.ignorelist.index(realname)
          info[:respond].call("#{info[:result]} is already on the ignore list.")
        else
          @ch.ignorelist << info[:result]
          info[:respond].call("Added #{info[:result]} to ignore list. (case insensitive)")
        end
      }
    end, Trigger.new do |t|
      t[:id] = 'console_unignore'
      t[:nolog] = true
      
      t.match { |info| 
        info[:where] == 's' &&
        info[:what][0..7] == "unignore" &&
        info[:what][9..-1]
      }
      
      t.act { |info| 
        realname = CBUtils.condense_name(info[:result])
        
        if @ch.ignorelist.delete(realname)
          info[:respond].call("Removed #{info[:result]} from ignore list. (case insensitive)")
        else
          info[:respond].call("#{info[:result]} is not on the ignore list")
        end
      }
    end, Trigger.new do |t|
      t[:id] = 'console_customsend'
      t[:nolog] = true
      
      t.match { |info| 
        info[:where] == 's' &&
        info[:what][0..0] == "s" &&
        info[:what][2..-1]
      }
      
      t.act { |info| 
        info[:ws].send(info[:result])
      }
    end, Trigger.new do |t|
      t[:id] = 'console_login'
      t[:nolog] = true
      
      t.match { |info| 
        info[:where] == 's' &&
        info[:what][0..0] == "l" &&
        info[:what][2..-1].split(' ')
      }
      
      t.act { |info| 
        next if info[:result].size != 2
        assertion = CBUtils.login(*info[:result])["assertion"]
        p assertion
        info[:ws].send("|/trn #{info[:result][0]},0,#{assertion}")
      }
    end, Trigger.new do |t|
      t[:id] = 'console_pry'
      t[:nolog] = true
      
      t.match { |info| 
        info[:what] == 'pry' && info[:where] == 's'
      }
      
      t.act { |info| 
        binding.pry
      }
    end]
    
  end
  
  def start_loop
    Thread::abort_on_exception = false
  
    
    
    @ci_thread = Thread.new do 
      begin
        
        while input = Readline.readline("console> ", true).strip
          message = ['s', input]
          @ch.handle(message, @ws)  # the ws field is left blank because there is no ws
        
        end
      rescue Exception => e
        puts e.message
        puts e.backtrace
      end
      
    end
    
    # Console triggers
    @ch.triggers.push(*@handler_triggers)
    @ci_thread
  end
  
  def self.end_thread
    @ci_thread.exit
    @ch.triggers.delete(*@handler_triggers)
  end
  
end
