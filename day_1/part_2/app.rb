NUMBERS=%w(one two three four five six seven eight nine ten)

def get_left_number(line)
    line_copy = line.dup
    while line_copy.length > 0
        return line_copy[0].to_i if line_copy[0].to_i > 0

        found_number = NUMBERS.find { |number| line_copy.start_with?(number) }
        return NUMBERS.index(found_number) + 1 if found_number

        line_copy = line_copy[1..-1]
    end
    return nil
end

def get_right_number(line)
    line_copy = line.dup
    while line_copy.length > 0
        return line_copy[-1].to_i if line_copy[-1].to_i > 0

        found_number = NUMBERS.find { |number| line_copy.end_with?(number) }
        return NUMBERS.index(found_number) + 1 if found_number

        line_copy = line_copy[0..-2]
    end
    return nil
end

result = File.open("../input.txt").readlines.map(&:chomp).inject(0) do |sum, line|
    left_number = get_left_number(line)
    right_number = get_right_number(line)
    sum += "#{left_number}#{right_number}".to_i
end

# Print the sum of all the sums
puts result
