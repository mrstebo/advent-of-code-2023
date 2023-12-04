class Game
    def initialize(line)
        @line = line
        @id = get_id
        @sets = get_sets
    end

    attr_reader :id, :sets

    private 

    attr_reader :line

    def get_id
        @line.match(/^Game (\d+):/)[1].to_i
    end

    def get_sets
        @line.sub(/^Game \d+: /, "").split(";").map(&:chomp).map do |set|
            hash = {}
            set.split(",").map(&:chomp).each do |item|
                count, color = item.split(" ")
                hash[color] = count.to_i
            end
            hash
        end
    end
end

bag_contents = {
    "red" => 12,
    "green" => 13,
    "blue" => 14,
}

result = File.open("../input.txt").readlines.map(&:chomp).inject(0) do |sum, line|
    game = Game.new(line)
    is_possible = game.sets.all? do |set|
        set.all? { |color, count| count <= bag_contents[color] }
    end
    sum += game.id if is_possible
    sum
end

# Print the sum of all the sums
puts result