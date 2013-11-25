def log *argv
  print "#{File.basename(__FILE__)}: "
  puts *argv
end

module ConsoleInput
  def self.init
    @@handler_triggers = [Trigger.new do |t|
      t[:id] = 'console_exit'
      
      t.match { |info|
        info[:where] == 's' &&
        info[:what] == 'exit'
      }
      
      t.act { |info|
        log 'exiting console...'
        end_thread
      }
    end, Trigger.new do |t|
      t[:id] = 'console_toff'
      
      t.match { |info| 
        info[:where] == 's' &&
        info[:what][0..3] == "toff" &&
        info[:what][5..-1]
      }
      
      t.act { |info| 
        ChatHandler.turn_by_id(info[:result], false) and puts "Turned off trigger: #{info[:result]}" or puts "No such trigger: #{info[:result]}"
      }
    end, Trigger.new do |t|
      t[:id] = 'console_ton'
      
      t.match { |info| 
        info[:where] == 's' &&
        info[:what][0..2] == "ton" &&
        info[:what][3..-1]
      }
      
      t.act { |info| 
        ChatHandler.turn_by_id(info[:result], true) and puts "Turned on trigger: #{info[:result]}" or puts "No such trigger: #{info[:result]}"
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
          ChatHandler.handle(message, ws)  # the ws field is left blank because there is no ws
        rescue Exception => e
          puts e.message
          puts e.backtrace
        end
      end
    end
    
    # Console triggers
    ChatHandler::TRIGGERS.push(*@@handler_triggers)
  end
  
  def self.end_thread
    @@ci_thread.exit
    ChatHandler::TRIGGERS.delete(*@@handler_triggers)
  end
  
end

ConsoleInput.init