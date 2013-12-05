require './showderp/pokemon-related/load.rb'

Trigger.new do |t|
  t[:id] = "rspd"
  
  t.match { |info|
    info[:what][0..4] == "!rspd" && info[:what].size > 4 &&
    info[:what][6..-1]
  }
  
  t.act do |info|
    $randbats_speeds == {} and $randbats_speeds = load_speeds
    result = $randbats_speeds[info[:result].downcase.gsub(/[^\w]/, '')]
    
    result = if result.nil?
      ""
    else
      "In randbats, #{info[:result].capitalize}'s speed is #{result}."
    end
    
    
    info[:respond].call(result)
  end
end