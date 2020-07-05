class Printer
  
  def print_rolling(string)
    if string == ""
      puts "rolling 1d6"
    else
      puts "rolling #{string}"
    end
  end

  def print_roll_results(result_array)
    result_array.each_with_index do |obj, index|
      print obj[:results].join(", ")
      print " / " if index != result_array.length - 1
    end
    puts
  end

  def print_results(result_string)
    print_marker
    puts result_string
  end

  private

  def print_marker
    print "=> "
  end

end