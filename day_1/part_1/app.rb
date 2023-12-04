result = File.open("../input.txt").readlines.map(&:chomp).inject(0) do |sum, line|
    numbers = line.split("").map(&:to_i).filter { |n| n > 0 }
    sum += "#{numbers.first}#{numbers.last}".to_i
end

# Print the sum of all the sums
puts result
