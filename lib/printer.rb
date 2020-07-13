class Printer
  
  def print_rolling(string = "1d6")
    puts "rolling #{string}"
  end

  def print_roll_outcomes(result_array)
    result_array.each_with_index do |obj, index|
      print obj[:results].join(", ")
      
      # if result_array has multiple items and this item is not the last one
      print "  /  " if index != result_array.length - 1
    end
    puts
  end

  def print_clause_result(result_string)
    print_marker
    puts result_string
  end

  private

  def print_marker
    print "=> "
  end

end