require 'optparse'

options = {}

OptionParser.new do |parser|
  parser.banner = "Usage: roll-cli.rb [options]"
  
  parser.on("-h", "--help", "Show this help message") do
    puts parser
  end

  parser.on("-n", "--name NAME", "The name of the person to greet.") do |v|
    options[:name] = v
  end

end.parse!

puts "Hello #{ options[:name] }" if options[:name]