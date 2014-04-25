# Book-loading utility to seed chain

require "./markovchains.rb"
require 'json'
chain_path = './chain.json'
books_path = './books/'

if !File.exist?(chain_path)
  File.open(chain_path, 'w') do |f| 
    f.puts '{}'
  end
end

print 'Loading current chain... '
chain = Markov.chain_from_json(File.open(chain_path).read)
puts 'done.'

puts 'Enter Book Filename: '
book = books_path + gets.chomp

File.foreach(book){|line| chain.add_words(line)}

puts 'Saving phrases...'
File.open(chain_path, 'w') do |f|
  f.puts JSON.dump(chain.nodes)
end
