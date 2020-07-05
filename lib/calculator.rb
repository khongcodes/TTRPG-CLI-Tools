class Calculator

  def roll(number = 1, dice = 6)
    result = []
    puts "rolling #{number}d#{dice}"
    
    number.times do
      dice_result = rand(1..dice)
      result.push(dice_result)
    end

    if number != 1
      print_dice(result)
      puts
    end

    print_sum(result)
  end

  def print_marker
    print "=> "
  end

  def print_dice(array)
    # print_marker
    print array.join(", ")
  end

  def print_sum(dice_array)
    print_marker
    puts dice_array.sum
  end
end