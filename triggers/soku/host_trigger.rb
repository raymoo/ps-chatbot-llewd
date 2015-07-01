$hosters = Hash.new
HostStruct = Struct.new(:hoster, :time, :address)

Trigger.new do |t|
  t[:id] = "host"
  
  t.match { |info|
    info[:what][0..5].downcase == '!host ' &&
    info[:what].length > 6 &&
    info[:what][6..-1]
  }
  
  t.act do |info|

    (info[:fullwho][0] =~ /[+%@#]/) or next

    hoster = CBUtils.condense_name(info[:who])
    hostinfo = HostStruct.new(info[:who], Time.now, info[:result])
    $hosters[hoster] = hostinfo

    info[:respond].call(hostinfo[:hoster] + " is hosting at " + hostinfo[:address])
  end
end