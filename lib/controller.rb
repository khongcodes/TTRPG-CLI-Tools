require_relative "./calculator"
require_relative "./printer"
# Each clause should return an array of dice-roll-outcome objects

class Controller
  
  @@arith_operator_regex = /(\+|\-)/
  @@number_clause = /\d+/
  @@modified_clause = /[hl]\d*{\d*d\d+}/

  def initialize
    @calculator = Calculator.new
    @printer = Printer.new
  end


  def no_clause 
    dice_outcomes = []
    dice_outcomes.push(@calculator.roll)

    result = {
      dice_outcome_array: dice_outcomes,
      roll_label: "1d6"
    }
    
    return result
  end


  def single_clause(clause, operator = "+")
    # puts "entering Controller#single_clause"
    # puts

    dice_outcomes = []

    operator_factor = operator == "+" ? 1 : -1
    clause_is_number = clause.match?(/\A#{@@number_clause}\z/)
    clause_is_modified = clause.match?(/\A#{@@modified_clause}\z/)

    if clause_is_number
      operated_number = operator_factor * clause.to_i
      dice_outcomes.push({
        results: [clause.to_i],
        reduction: operated_number
      })
    
    else

      if clause_is_modified
        flag = clause.split(/{|}/)[0]
        split_clause = clause.split(/{|}/)[1].split("d")
        
        # puts "#{split_clause}"
        # puts flag

        number_of_dice = split_clause[0] == "" ? 1 : split_clause[0].to_i
        dice_value = split_clause[1].to_i
        unmodified_roll = @calculator.roll(number_of_dice, dice_value)
        
        # puts unmodified_roll

        modify_number = flag[1] || 1
        sorted_results = []

        if flag[0] == "h"
          sorted_array = unmodified_roll[:results].sort{|a,b| b <=> a}
        elsif flag[0] == "l"
          sorted_array = unmodified_roll[:results].sort{|a,b| a <=> b}
        end

        new_sum = sorted_array.slice(0, modify_number.to_i).sum

        # puts "sorted array: #{sorted_array}"
        # puts sorted_array.slice(0, modify_number.to_i).sum

        pre_operator_roll = ({
          results: sorted_array,
          reduction: new_sum,
          flag: flag
        })


      else
        split_clause = clause.split("d")
      
        if split_clause[0] == ""
          number_of_dice = 1
        else
          number_of_dice = split_clause[0].to_i
        end

        dice_value = split_clause[1].to_i
        pre_operator_roll = @calculator.roll(number_of_dice, dice_value)
      end

      if operator_factor < 0
        dice_outcomes.push({
          results: pre_operator_roll[:results].map{|n| n * operator_factor},
          reduction: pre_operator_roll[:reduction] * operator_factor,
          flag: pre_operator_roll[:flag] || nil
        })
      else
        dice_outcomes.push(pre_operator_roll)
      end
    
    end

    result = {
      dice_outcome_array: dice_outcomes,
      roll_label: clause
    }

    # puts
    # puts "exiting Controller#single_clause"
    return result
  end


  def multi_clause(rolls_array)
    roll_label = ""
    dice_outcomes = []

    rolls_array.each_with_index do |c, index|
      roll_label.concat(" #{c[:operator]} ") unless index == 0
      roll_label.concat(c[:value])
    end

    rolls_array.each do |clause|
      dice_outcomes.push(single_clause(clause[:value], clause[:operator])[:dice_outcome_array][0])
    end

    result = {
      dice_outcome_array: dice_outcomes,
      roll_label: roll_label
    }

    return result
  end


  def multi_arg(arguments_array)
    clauses_result = []
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
      
      sorted_clauses.each do |c|
        combined_clause_obj = c.class == String ? single_clause(c) : multi_clause(c)
        clauses_result.push(combined_clause_obj)
      end

    else
      clauses_result.concat(arguments_array.map{|arg| single_clause(arg)})
    end

    return clauses_result
  end

end