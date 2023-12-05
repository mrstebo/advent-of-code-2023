class Gear
    def initialize(left, right)
        @left = left
        @right = right
    end

    def ratio
        @left * @right
    end

    def to_s
        "Gear: #{@left} * #{@right} = #{ratio}"
    end
end

class Schematic
    def initialize
        @data = File.open("../input.txt").readlines.map(&:chomp)
    end

    def gears
        results = []
        0.upto(@data.length - 1).each do |row|
            @data[row].enum_for(:scan, /\*/)
                .map { Regexp.last_match.begin(0) }
                .each do |col|
                    build_gears(row, col).each do |gear|
                        results << gear
                    end
                end
        end
        results
    end

    private

    def build_gears(row, col)
        # Get the surrounding numbers
        top = @data[row - 1][col - 1..col + 1]
        middle = @data[row][col - 1..col + 1]
        bottom = @data[row + 1][col - 1..col + 1]

        # Get any adjacent numbers
        top_left, top_right = get_adjacent_numbers(row - 1, col)
        middle_left, middle_right = get_adjacent_numbers(row, col)
        bottom_left, bottom_right = get_adjacent_numbers(row + 1, col)

        # Combine the numbers
        top = top_left + top + top_right
        middle = middle_left + middle + middle_right
        bottom = bottom_left + bottom + bottom_right

        # Get the numbers from the strings (split by space to avoid joining two rows)
        numbers = [top, middle, bottom].join(" ").scan(/\d+/).map(&:to_i)

        # Only return gears if there are at 2 numbers
        if numbers.length <= 1 || numbers.length > 2
            return []
        end

        # Create gears from each pair of numbers
        results = []
        numbers.each_cons(2) do |pair|
            results << Gear.new(pair[0], pair[1])
        end

        results
    end

    def get_adjacent_numbers(row, col)
        left = ""
        index = col - 1
        while index >= 0 && @data[row][index] =~ /\d/
            left = @data[row][index] + left
            index -= 1
        end

        right = ""
        index = col + 1
        while index < @data[row].length && @data[row][index] =~ /\d/
            right += @data[row][index]
            index += 1
        end

        [left[0..-2] || "", right[1..-1] || ""]
    end
end

schematic = Schematic.new

result = schematic.gears.inject(0) do |sum, gear|
    puts gear
    sum += gear.ratio
end

puts result