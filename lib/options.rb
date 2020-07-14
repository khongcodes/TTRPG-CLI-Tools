require "optparse"

class Options
  attr_accessor :options, :opened
  
  def initialize
    @options = {}
    @opened = false
  end
  
  def parse
    OptionParser.new do |parser|
      parser.banner = <<~BANNER
        Usage: roll-cli.rb [arguments] OR [options]

        See option -a for help formatting arguments.
        If a valid option is passed, no dice will be rolled.

      BANNER
  
      parser.on("-h", "--help", "Show this help message") do
        @opened = true
        puts parser
        puts
      end

      parser.on("-a", "--arguments", "Show help message for arguments") do
        @opened = true
        help_text = <<~HELPTEXT
          Arguments format:
            - Zero or more groups of roll expressions, separated by spaces
          

            [Roll expression] format:
              - [number of dice to roll (optional)] "d" [number of sides on that dice]
              - The output will be the sum of the die results

              - Valid roll expressions:   2d6, d20, 4d8
              - Invalid roll expressions: 2d0, 4d,  d
            

            [Roll expressions] can be prefixed with a modifier flag to sum the highest or lowest of the 
            die results for a given number of them
              - the flags are 'h' for highest, 'l' for lowest. The rest of the expression is wrapped in 
                brackets
              - the modifier flag number cannot be higher than the amount of dice rolled

              - Valid modified roll expressions:    l{3d20},  h2{3d6},  h{1d20}
              - Invalid modified roll expressions:  {3d20},   l5{3d6},  l{2d0}
            

            [Roll expression groups] are rolls modified with arithmetic, added to other rolls or 
            numeric values
              - A roll expression group is valid if all of its expressions are valid. For this purpose, 
                numeric values are valid roll expressions.
              - A roll expression group can have just one expression.
              
              - Valid roll expression groups:   4d4 + 5,  2d6 - h{2d20},  4
              - Invalid roll expression groups: 8d0 + 8,  + 8d6 -,     d
          
          
          Valid arguments: 3d6 + 4 h2{3d6} 5d8 - 4
          Invalid arguments: 3d6 - - 4d0 5d6 +

          If a valid option is passed, no dice will be rolled.

        HELPTEXT
        
        puts help_text
      end

      parser.on("-t", "--tarot NUMBER", "The number of tarot cards to draw") do |n|
        # puts "test"
        @opened = true
        # puts "#{n}"
        @options[:option] = "t"
        @options[:number_of_cards] = n
      end

      parser.on("-p", "--playing_card NUMBER", "The number of playing cards to draw") do |n|
        @opened = true
        @options[:option] = "p"
        @options[:number_of_cards] = n
      end
    end.parse!
  end
end