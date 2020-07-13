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
require_relative "./controller"
require "optparse"

class Cli
  attr_accessor :options_opened

  # start of string, 0 or more digits, "d", 1 or more digits, end of string
  regular_clause = /\d*d\d+/
  number_clause = /\d+/
  modified_clause = /[hl]\d*{\d*d\d+}/
  valid_single_clause = /(#{regular_clause}|#{number_clause}|#{modified_clause})/
  @@arith_operator_regex = /(\+|\-)/
  @@valid_dice_regex = /\A#{valid_single_clause}\z/
  @@multi_clause_single_regex = /\A#{valid_single_clause}|\+|\-\z/

  def initialize(arg_array)
    @calc = Calculator.new
    @printer = Printer.new
    @controller = Controller.new
    @options_opened = false
    @options = {}
  end

  def option_parse
    OptionParser.new do |parser|
      parser.banner = "Usage: roll-cli.rb [options]"
  
      parser.on("-h", "--help", "Show this help message") do
        @options_opened = true
        puts parser
      end

      parser.on("-t", "--tarot NUMBER", "The number of tarot cards to draw") do |v|
        @options_opened = true
        @options[:name] = v
      end

      parser.on("-p", "--playing_card NUMBER", "The number of playing cards to draw") do |v|
        @options_opened = true
        @options[:name] = v
      end
    end.parse!
  end

  def run
    # puts "entering Cli#run"
    # puts
    option_parse

    # puts "Arguments: #{ARGV}"
    # puts @options_opened
    # puts @options


    # return if @options_opened

    no_arg = ARGV.length == 0
    command_is_single = ARGV.length == 1
    
    if no_arg
      print_result(@controller.no_clause)

    elsif command_is_single
      clause = ARGV[0]
      if validate_input("single roll", clause)
        print_result(@controller.single_clause(clause))
      end

    else # multiple arguments
      if validate_input("multi clause", ARGV)
        # multi-clause, single clause
        # [[{}, {}], [{}]]
        agg_result = @controller.multi_arg(ARGV)
        agg_result.each {|r| print_result(r)}
      end
    end

  end


  def print_result(result_obj)
    @printer.print_rolling(result_obj[:roll_label])

    sum_of_reductions = @calc.calculate(result_obj[:dice_outcome_array])
    @printer.print_roll_outcomes(result_obj[:dice_outcome_array])
    @printer.print_clause_result(sum_of_reductions)
    puts
  end



  def validate_input(input_type, input)
    error = false

    case input_type
    when "single roll"
      error = "invalid dice roll format" if !input.match?(@@valid_dice_regex)
    
    when "multi clause"
      if input[0].match?(@@arith_operator_regex) || input[input.length - 1].match?(@@arith_operator_regex)
        error = "first/last arg operator"

      # add elsif for consecutive operator arguments
      # add elsif modifier number cannot be 0
      # add elsif for modifier number too large

      elsif input.reject{|c|c.match?(@@multi_clause_single_regex)}.length != 0
        error = "invalid dice roll format"
      end
    end

    puts "error: #{error ?  error : "none"}"
    puts
    print_error(error) if error
    return !error
  end


  def print_error(error_type)
    message = ""

    case error_type
    when "invalid dice roll format"
      message = "input is invalid format.\nTry formatting like \"2d6\" or \"d20\" or \"l3{5d20}\".\nTry entering the -h tag to see HELP."
    when "first/last arg operator"
      message = "first and last arguments cannot be an arithmetic operator."
    end

    puts "ERROR: #{message}"
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
