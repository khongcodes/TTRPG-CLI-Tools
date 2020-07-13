require_relative "./calculator"
require_relative "./printer"
require_relative "./controller"
require "optparse"

class Cli
  attr_accessor :options_opened

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
            # puts modifier_too_large
            # break

          end  
        end
      end

      puts modifier_too_large

      
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
    end

    # puts "error: #{error ?  error : "none"}"
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
    end
  
    puts "ERROR: #{message}"
  end

  

end



####################################################

# tarot
# playing-card-deck
