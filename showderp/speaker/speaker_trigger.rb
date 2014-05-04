require "./showderp/speaker/markovchains.rb"
require 'json'
require 'uri'

Trigger.new do |t|
  t[:id] = 'speaker'
  
  t.match { |info|
    (info[:where] == 'c') && info[:what]
  }
  
  t[:id] = "speaker"
  $speakable = Hash.new
  $speakable.default = true
  chain_path = './showderp/speaker/chain.json'
  if !File.exist?(chain_path)
    File.open(chain_path, 'w') do |f| 
      f.puts '{}'
    end
  end
  
  print 'Loading phrases I know...  '
  chain = Markov.chain_from_json(File.open(chain_path).read)
  puts 'done.'
  
  t.act do |info|
    text = info[:result].gsub(URI.regexp, '') # remove links
    
    name = USERNAME
    
    if text[0..name.size].downcase == "#{name.downcase},"
<<<<<<< HEAD
      next if info[:who] == USERNAME
      (info[:all][2][0] == '#' || info[:all][2][0] == '@' || info[:all][2][0] == '%' || info[:all][2][0] == '+') or next
    
      words = text[name.size..-1].split(' ')
      seed = nil
      
      chain.nodes.each do |keys, values|
        if words.reverse.any? { |word| keys.index(word) }
          seed = keys
          break
        end
      end
      
      info[:respond].call("(#{info[:who]}) #{chain.generate(20, seed).join(' ')}.")
    else
      chain.add_words(text)
    end
  end
  
  t.exit do
    puts 'Saving phrases I know...'
    File.open(chain_path, 'w') do |f|
      f.puts JSON.dump(chain.nodes)
    end
  end
end
