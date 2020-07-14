require_relative "./calculator"
require_relative "./printer"
require_relative "./controller"
require_relative "./options"
require_relative "./deck"
require "optparse"

class Cli
  # attr_accessor :options_opened

  # start of string, 0 or more digits, "d", 1 or more digits, end of string
  regular_clause = /\d*d\d+/
  number_clause = /\d+/
  @@modified_clause = /[hl]\d*{#{regular_clause}}/
  valid_single_clause = /(#{regular_clause}|#{number_clause}|#{@@modified_clause})/
  @@arith_operator_regex = /(\+|\-)/
  @@valid_dice_regex = /\A#{valid_single_clause}\z/
  @@multi_clause_single_regex = /\A#{valid_single_clause}|\+|\-\z/

  def initialize(arg_array)
    @calc = Calculator.new
    @printer = Printer.new
    @controller = Controller.new
    @options = Options.new
    @deck = Deck.new
  end

  def run
    return if option_parse

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
    puts
    @printer.print_rolling(result_obj[:roll_label])
    sum_of_reductions = @calc.calculate(result_obj[:dice_outcome_array])
    @printer.print_roll_outcomes(result_obj[:dice_outcome_array])
    @printer.print_clause_result(sum_of_reductions)
    puts
  end


  def option_parse
    break_run = false

    begin
      @options.parse
    rescue => exception 
      break_run = true
      case exception.to_s.split("-")[1]
        when "t"
          print_error("option t bad arg")
        when "p"
          print_error("option p bad arg")
        else
          print_error("invalid option")
      end
    end

    if @options.opened
      break_run = true
      if validate_input("options", @options.options)
        puts "nice"
      end
    end

    return break_run
  end



  def validate_input(input_type, input)
    error = false

    case input_type
    when "single roll"
      error = "zero sided dice" if /\d*d0/.match?(input)
      error = "invalid dice roll format" if !input.match?(@@valid_dice_regex)
      error = "modifier zero" if /\A[hl]0{.+}\z/.match?(input)
      
      if !error && /\A#{@@modified_clause}\z/.match?(input)
        split_input = input.split(/{|}/)
        flag_num = split_input[0].split(/[hl]/)[1] || 1
        dice_num = split_input[1].split("d")[0]
        error = "modifier too large" if flag_num.to_i > dice_num.to_i
      end
    
    when "multi clause"
      puts "input: #{input}"
      
      zero_sided_dice = false
      consecutive_operators = false
      modifier_is_zero = false
      modifier_too_large = false

      input.each_with_index do |a, index|
        if /\A\d*d0\z/.match?(a)
          zero_sided_dice = true
          break

        elsif index < input.length - 2 && @@arith_operator_regex.match?(a)
          consecutive_operators = true if @@arith_operator_regex.match?(input[index + 1])
          break

        elsif /\A#{@@modified_clause}\z/.match?(a)
          if /\A[hl]0{.+}\z/.match?(a)
            modifier_is_zero = true
            break

          else
            split_input = a.split(/{|}/)
            flag = split_input[0]
            dice = split_input[1]
            flag_num = flag.split(/[hl]/)[1] || 1
            dice_num = dice.split("d")[0]
            modifier_too_large = flag_num.to_i > dice_num.to_i
            break
          end  
        end
      end

      if zero_sided_dice
        error = "zero sided dice"
      elsif input[0].match?(@@arith_operator_regex) || input[input.length - 1].match?(@@arith_operator_regex)
        error = "first/last arg operator"
      elsif consecutive_operators
        error = "consecutive operators"
      elsif modifier_is_zero
        error = "modifier zero"
      elsif modifier_too_large
        error = "modifier too large"
      elsif input.reject{|c|c.match?(@@multi_clause_single_regex)}.length != 0
        error = "invalid dice roll format"
      end

    when "options"
      case input[:option]
      when "t"
        target_number = 78
      when "p"
        target_number = 52
      end
      
      input_too_low = input[:number_of_cards].to_i <= 0
      input_too_high = input[:number_of_cards].to_i > target_number

      error = "option #{input[:option]} bad arg" if input_too_low || input_too_high

    end


    puts
    print_error(error) if error
    return !error
  end


  def print_error(error_type)
    message = ""

    case error_type
    when "zero sided dice"
      message = "Dice side value cannot be zero.\nTry entering the -h tag to see HELP."
    when "invalid dice roll format"
      message = "Input is invalid format.\nTry formatting like \"2d6\" or \"d20\" or \"l3{5d20}\".\nTry entering the -h tag to see HELP."
    when "first/last arg operator"
      message = "First and last arguments cannot be an arithmetic operator.\nTry entering the -h tag to see HELP."
    when "consecutive operators"
      message = "Input cannot have consecutive operators.\nTry entering the -h tag to see HELP."
    when "modifier zero"
      message = "Modifier amount cannot be zero.\nTry entering the -h tag to see HELP."
    when "modifier too large"
      message = "Modifier cannot be higher than the number of dice rolled.\nTry entering the -h tag to see HELP."
    when "invalid option"
      message = "Invalid option.\nTry entering the -h tag to see HELP."
    when "option t bad arg"
      message = "Bad argument. Your option needs to be followed by a number between 1 and 78."
    when "option p bad arg"
      message = "Bad argument. Your option needs to be followed by a number between 1 and 52."
    end
  
    puts "ERROR: #{message}"
    puts
  end

end