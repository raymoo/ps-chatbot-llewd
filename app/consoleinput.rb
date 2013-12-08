require 'pry'

module ConsoleInput
  def self.init
    @@handler_triggers = [Trigger.new do |t|
      t[:id] = 'console_exit'
      t[:nolog] = true
      
      t.match { |info|
        info[:where] == 's' &&
        info[:what] == 'exit'
      }
      
      t.act { |info|
        puts 'exiting console...'
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
        if $chat.turn_by_id(info[:result], false)
          puts "Turned off trigger: #{info[:result]}"
        else
          puts "No such trigger: #{info[:result]}"
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
        if $chat.turn_by_id(info[:result], true)
          puts "Turned on trigger: #{info[:result]}"
        else
          puts "No such trigger: #{info[:result]}"
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
        
        if $chat.ignorelist.index(realname)
          puts "#{info[:result]} is already on the ignore list."
        else
          $chat.ignorelist << info[:result]
          puts "Added #{info[:result]} to ignore list. (case insensitive)"
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
        
        if $chat.ignorelist.delete(realname)
          puts "Removed #{info[:result]} from ignore list. (case insensitive)"
        else
          puts "#{info[:result]} is not on the ignore list"
        end
      }
    end, Trigger.new do |t|
      t[:id] = 'console_customsend'
      t[:nolog] = true
      
      t.match { |info| 
        info[:where] == 's' &&
        info[:what][0..1] == "s" &&
        info[:what][2..-1]
      }
      
      t.act { |info| 
        info[:ws].send(info[:result])
      }
    end, Trigger.new do |t|
      t[:id] = 'console_pry'
      t[:nolog] = true
      
      t.match { |info| 
        info[:what] == 'pry'
      }
      
      t.act { |info| 
        binding.pry
      }
    end]
  end
  
  def self.start_loop ws
    @@ci_thread = Thread.new do
      loop do
        begin
          print "console> "
          input = gets.strip
          message = ['s', input]
          $chat.handle(message, ws)  # the ws field is left blank because there is no ws
        rescue Exception => e
          puts e.message
          puts e.backtrace
        end
      end
    end
    
    # Console triggers
    $chat.triggers.push(*@@handler_triggers)
    @@ci_thread
  end
  
  def self.end_thread
    @@ci_thread.exit
    $chat.triggers.delete(*@@handler_triggers)
  end
  
end

ConsoleInput.init