class PartNumber
    def initialize(number, row, col)
        @number = number
        @row = row
        @col = col
    end

    attr_reader :number, :row, :col

    def to_s
        "PartNumber: #{@number} at row: #{@row}, col: #{@col}"
    end
end

class Schematic
    def initialize
        @data = File.open("../input.txt").readlines.map(&:chomp)
    end

    def get_part_numbers
        part_numbers = []
        0.upto(@data.length - 1).each do |row|
            pcol = 0
            numbers_with_index = @data[row].scan(/(\d+)/).each do |captures|
                captures.each do |capture|
                    col = @data[row][pcol..-1].index(capture) + pcol
                    part_numbers << PartNumber.new(capture.to_i, row + 1, col) if check_is_part_number?(capture, row, col)
                    pcol = col + capture.length - 1
                end
            end
        end
        part_numbers
    end

    private

    def check_is_part_number?(number, row, col)
        # Check same row
        return true if col > 0 && check_is_symbol?(row, col - 1)
        return true if col < @data[row].length - 1 && check_is_symbol?(row, col + number.length)
        
        # Check next row (also supports diagnols)
        return true if row < @data.length - 1 && check_has_symbol?(row + 1, col - 1, col + number.length + 1)
        return true if row <= @data.length - 1 && check_has_symbol?(row - 1, col - 1, col + number.length + 1)
        false
    end

    def check_is_symbol?(row, col)
        return true if @data[row][col] && @data[row][col].match?(/[^.\d]/)
        false
    end

    def check_has_symbol?(row, col_start, col_end)
        actual_col_start = col_start < 0 ? 0 : col_start
        actual_col_end = col_end > @data[row].length - 1 ? @data[row].length - 1 : col_end
        return true if @data[row][actual_col_start...actual_col_end].match?(/[^.\d]/)
        false
    end
end

schematic = Schematic.new

result = schematic.get_part_numbers.inject(0) do |sum, part_number|
    puts part_number
    sum += part_number.number
end

puts result