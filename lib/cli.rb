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
  attr_accessor :command_array, :result_array, :memo

  # start of string, 0 or more digits, "d", 1 or more digits, end of string
  valid_single_clause = /(\d*d\d+|\d+)/
  @@arith_operator_regex = /(\+|\-)/
  @@valid_dice_regex = /\A#{valid_single_clause}\z/
  @@multi_clause_single_regex = /\A#{valid_single_clause}|\+|\-\z/

  def initialize(arg_array)
    @command_array = arg_array
    @result_array = []
    @calc = Calculator.new
    @printer = Printer.new
    @memo = nil
  end

  def run
    # @printer.print_rolling(ARGV)

    no_arg = ARGV.length == 0
    command_is_single = ARGV.length == 1
    
    if no_arg
      process_no_clause

    elsif command_is_single
      clause = ARGV[0]
      process_single_clause(clause)

    else
      process_multi_clause(ARGV)

    end

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


  def process_reduce_clause(array)
    print "rolling "
    array.each_with_index do |c, index|
      print " #{c[:operator]} " unless index == 0
      print "#{c[:value]}"
    end
    puts

    roll_results = []

    array.each do |clause|
      operator_factor = clause[:operator] == "+" ? 1 : -1
      clause_is_number = clause[:value].match?(/\A\d+\z/)

      if clause_is_number
        operated_number = operator_factor * clause[:value].to_i
        roll_results.push({
          results: [operated_number],
          reduction: operated_number
        })

      else
        # @printer.print_rolling(clause[:value])
        split_value = clause[:value].split("d")
        
        if split_value[0] == ""
          number_of_dice = 1
        else
          number_of_dice = split_value[0].to_i
        end

        dice_value = split_value[1].to_i

        rolled_value = @calc.roll(number_of_dice, dice_value)
        rolled_value[:reduction] = operator_factor * rolled_value[:reduction]
        rolled_value[:results].map!{|n|operator_factor * n}

        roll_results.push(rolled_value)
      end

    end

    # puts "#{roll_results}"
    print_result(roll_results)
  end

  def process_multi_clause(arguments_array)
  
    if arguments_array[0].match?(@@arith_operator_regex)
      print_error("first arg operator")

    elsif arguments_array[arguments_array.length - 1].match?(@@arith_operator_regex)
      print_error("last arg operator")

    elsif !validate_input("multi clause", arguments_array)
      print_error("invalid dice roll format")

    else
      arith_present = arguments_array.any?(@@arith_operator_regex)

      # PREPARE TO MATH
      if arith_present
        # puts "#{arguments_array}"
        sorted_clauses = []

        arguments_array.each_with_index do |arg, index|
          this_arg_is_operator = arg.match?(@@arith_operator_regex)
          
          # if arg is last element in array, next_arg_is_operator is automatically false
          # otherwise check if next arg is operator
          if index == arguments_array.length - 1
            next_arg_is_operator = false
          else
            next_arg_is_operator = arguments_array[index + 1].match?(@@arith_operator_regex) 
          end

          # at first arg
          # if next arg is not an operator, push simple value to sorted_clauses
          if index == 0 && !next_arg_is_operator
            sorted_clauses.push(arg)
          
          # if next arg is an operator, prepare a calculation group
          elsif index == 0
            sorted_clauses.push([{
              value: arg,
              operator: "+"
            }])
            @memo = 0

          # for arguments not the first argument -
          else
            last_arg_was_operator = arguments_array[index - 1].match?(@@arith_operator_regex)

            # if next arg is operator and this is not and last was not, prepare a calculation group
            if next_arg_is_operator && !this_arg_is_operator && !last_arg_was_operator
              sorted_clauses.push([{
                value: arg,
                operator: "+"
              }])
              @memo = sorted_clauses.length - 1
              
            # if last arg was operator, apply to this dice value and add to memo-d calculation group
            elsif last_arg_was_operator && !this_arg_is_operator
              sorted_clauses[@memo].push({
                value: arg,
                operator: arguments_array[index - 1]
              })

            # if clauses separate from calculation groups
            elsif !last_arg_was_operator && !this_arg_is_operator
              sorted_clauses.push(arg)
            end

          end

        end

        # puts "#{sorted_clauses.map{|c|c.class}}"
        # puts "#{sorted_clauses}"

        sorted_clauses.each do |c|
          if c.class == String
            process_single_clause(c)
          else
            process_reduce_clause(c)
          end
        end

      else # !arith_present
        arguments_array.each do |a|
          process_single_clause(a)
        end
      end
      
    end
  end

  def print_result(result_array)
    result = @calc.calculate(result_array)
    @printer.print_roll_results(result_array)
    @printer.print_results(result)
    puts
  end


  def print_error(error_type)
    message = ""

    case error_type
    when "invalid dice roll format"
      message = "input is invalid format.\nTry formatting like \"2d6\" or \"d20\"."
    when "first arg operator"
      message = "first argument cannot be operator."
    when "last arg operator"
      message = "last argument cannot be operator."
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
