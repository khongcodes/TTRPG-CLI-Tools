require_relative "./calculator"
require_relative "./printer"
# Each clause should return an array of dice-roll-outcome objects

class Controller
  
  @@arith_operator_regex = /(\+|\-)/

  def initialize
    @calculator = Calculator.new
    @printer = Printer.new
  end


  def no_clause 
    puts "entering Controller#no_clause"
    puts
    @printer.print_rolling

    result = []
    result.push(@calculator.roll)
    
    puts
    puts "exiting Controller#no_clause"
    return result
  end


  def single_clause(clause, operator = "+")
    puts "entering Controller#single_clause"
    puts
    @printer.print_rolling(clause)

    result = []
    result.push({"type": "single"}) #TODO

    # {
    #   results: [clause.to_i],
    #   reduction: clause.to_i 
    # }

    puts
    puts "exiting Controller#single_clause"
    return result
  end


  def multi_clause(rolls_array)
    puts "entering Controller#multi_clause"
    puts


    roll_label = ""
    rolls_array.each_with_index do |c, index|
      roll_label.concat(" #{c[:operator]} ") unless index == 0
      roll_label.concat(c[:value])
    end
    # puts

    result = []

    rolls_array.each do |clause|
      operator_factor = clause[:operator] == "+" ? 1 : -1
      clause_is_number = clause[:value].match?(/\A\d+\z/)

      if clause_is_number
        operated_number = operator_factor * clause[:value].to_i
        result.push({
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

        rolled_value = @calculator.roll(number_of_dice, dice_value)
        rolled_value[:reduction] = operator_factor * rolled_value[:reduction]
        rolled_value[:results].map!{|n|operator_factor * n}

        result.push(rolled_value)
      end

    end

    # result.push({"type": "multi"}) #TODO

    puts
    puts "exiting Controller#multi_clause"
    return result
  end


  def multi_arg(arguments_array)
    puts "entering Controller#multi_roll"
    puts

    result = []
    arith_present = arguments_array.any?(@@arith_operator_regex)

    if arith_present
      sorted_clauses = []
      # type sorted_clauses = {
      #   value: string
      #   operator: "+" | "-"
      # }[]

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

      puts "sorted clauses: #{sorted_clauses}"
      
      sorted_clauses.each do |c|
        combined_clause_obj = c.class == String ? single_clause(c) : multi_clause(c)
        result.push(combined_clause_obj)
      end

    else
      result.concat(arguments_array.map{|arg| single_clause(arg)[0]})
    end

    puts
    puts "exiting Controller#multi_roll"
    return result
  end

end