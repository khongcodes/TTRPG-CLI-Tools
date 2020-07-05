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
require_relative "./printer"

class Cli
  attr_accessor :command_array, :result_array

  # start of string, 0 or more digits, "d", 1 or more digits, end of string
  valid_single_clause = /(\d*d\d+|\d+)/
  @@valid_dice_regex = /\A#{valid_single_clause}\z/
  @@multi_clause_single_regex = /\A#{valid_single_clause}|\+|\-\z/

  def initialize(arg_array)
    @command_array = arg_array
    @result_array = []
    @calc = Calculator.new
    @printer = Printer.new
  end

  def run
    # @printer.print_rolling(ARGV)

    no_arg = ARGV.length == 0
    command_is_single = ARGV.length == 1
    command_has_arithm = command_array.any?(/(\+|\-)/)
    
    if no_arg
      process_no_clause

    elsif command_is_single
      clause = ARGV[0]
      process_single_clause(clause)
    # elsif command_has_arithm
    else
      process_multi_clause(ARGV)
    end


    # if command_has_arithm
    #   puts "arithm"
    # else
    #   puts "no arithm"
    # end
  end

  def validate_input(input_type, input)
    case input_type
    when "single roll"
      return input.match?(@@valid_dice_regex)
    when "multi clause"
      # input.each do |c|
      #   puts c.match?(@@multi_clause_single_regex)
      # end
      return input.reject{|c|c.match?(@@multi_clause_single_regex)}.length == 0
    end
  end


  def process_no_clause
    @printer.print_rolling("")
    @result_array.push(@calc.roll)
    print_result(@result_array)
  end

  def process_single_clause(clause, operator = "+")
    if validate_input("single roll", clause)
      result_array = []

      clause_is_number = clause.match?(/\A\d+\z/)
      
      if clause_is_number
        result_array.push({
          results: [clause.to_i],
          reduction: clause.to_i 
        })

      else
        @printer.print_rolling(clause)

        split_clause = clause.split("d")
        
        if split_clause[0] == ""
          number_of_dice = 1
        else
          number_of_dice = split_clause[0].to_i
        end

        dice_value = split_clause[1].to_i
        result_array.push(@calc.roll(number_of_dice, dice_value))  

      end

      print_result(result_array)
    else
      print_error("invalid dice roll format")
    end
  end

  def process_multi_clause(arguments_array)
    if validate_input("multi clause", arguments_array)
      if arguments_array.any?(/(\+|\-)/)
        puts "math"

      else
        arguments_array.each do |a|
          process_single_clause(a)
          puts
        end
      end

    else
      print_error("invalid dice roll format")
    end
  end

  def print_result(result_array)
    result = @calc.calculate(result_array)
    @printer.print_roll_results(result_array)
    @printer.print_results(result)
  end


  def print_error(error_type)
    message = ""

    case error_type
    when "invalid dice roll format"
      message = "input is invalid format.\nTry formatting like \"2d6\" or \"d20\"."
    end

    puts "ERROR: #{message}"
    return
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
