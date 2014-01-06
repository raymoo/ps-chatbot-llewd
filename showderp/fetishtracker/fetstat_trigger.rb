Trigger.new do |t|
  t[:id] = 'fetstat'

  t.match { |info|
    # checks
  
  }
  
  t.act { |info|
    # if those checks pass
  }
end
