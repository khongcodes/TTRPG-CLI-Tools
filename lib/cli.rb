# require 'optparse'

# options = {}

# OptionParser.new do |parser|
#   parser.banner = "Usage: roll-cli.rb [options]"
  
#   parser.on("-h", "--help", "Show this help message") do
#     puts parser
#   end

#   parser.on("-n", "--name NAME", "The name of the person to greet.") do |v|
#     options[:name] = v
#   end

# end.parse!

# puts "Hello #{ options[:name] }" if options[:name]

# for arg in ARGV
#   puts arg
# end
require_relative "./calculator"

class Cli
  attr_accessor :command_array, :result_array

  # start of string, 0 or more digits, "d", 1 or more digits, end of string
  @@valid_dice_regex = /\A\d*d\d+\z/
  

  def initialize(arg_array)
    @command_array = arg_array
    @result_array = []
    @calc = Calculator.new  
  end

  def run
    no_arg = ARGV.length == 0
    command_is_single = ARGV.length == 1
    command_has_arithm = command_array.any?(/(\+|\-)/)
    
    if no_arg
      @calc.roll
    end

    if command_is_single
      command = ARGV[0]

      if validate_input("single roll", command)
        split_command = command.split("d")
        
        if split_command[0] == ""
          number_of_dice = 1
        else
          number_of_dice = split_command[0].to_i
        end

        dice_value = split_command[1].to_i
        @calc.roll(number_of_dice, dice_value)
      else
        print_error("invalid dice roll format")
      end
    end


    if command_has_arithm
      puts "arithm"
    else
      puts "no arithm"
    end


  end

  def validate_input(input_type, input)
    case input_type
    when "single roll"
      return input.match?(@@valid_dice_regex)
    end
  end

  def print_result
  end


  def print_error(error_type)
    message = ""

    case error_type
    when "invalid dice roll format"
      message = "input is invalid format.\nTry formatting like \"2d6\" or \"d20\"."
    end

    puts "ERROR: #{message}"
    return
    puts "stuff3"
  end

end
# roll 2d6
# command = ARGV[0]
# test1 = "2d6"
# test2 = "2d6 + 2".split(" ")
# test3 = "2d6 + 2 - 1d6".split(" ")
# # command.split(" ")
# command_has_arithm = ARGV.any?(/(\+|\-)/)
# if command_has_arithm

# end
# puts 

# roll 2d6
# => 1 + 6 = 7
# => 7

# roll 4d6
# => 4 + 2 + 4 + 5 = 15
# => 15


# options
# ADVANTAGE - take best of X
# roll 3d6 -h 2
# roll 3d6 --highest 2
# roll h(2)(3d6)
# => 4, 4, 2
# => 4 + 4 = 8
# => 8

# DISADVANTAGE - take worst of X
# roll 3d6 -l 2
# roll 3d6 --lowest 2
# roll l(2)(3d6)
# => 4, 4, 2
# => 4 + 2 = 6
# => 6

# errorif: h(3)(2d6) or l(3)(2d6)
# error: can't take highest 3 out of 2 dice

# 1d20 + 2 + 1d6 - l(2d6)
# => 16 / 2 / 5 / 3, 2
# => 16 + 2 + 5 - 2 = 21
# => 21

####################################################
# fitd - take highest result
# roll 4d6 -f
# roll h(4d6)
# => 5, 2, 1, 4
# => 5

# tarot
# playing-card-deck
