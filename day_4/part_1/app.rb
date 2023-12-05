class ScratchCard
    def initialize(line)
        @id = line.match(/^Card\s+(\d+):/)[1].to_i
        @winning_numbers = line.split(":")[1].split("|")[0].split(" ").map(&:to_i)
        @actual_numbers = line.split(":")[1].split("|")[1].split(" ").map(&:to_i)
    end

    attr_reader :id, :winning_numbers, :actual_numbers

    def score
        matches = @winning_numbers & @actual_numbers

        return 0 if matches.length == 0

        0.upto(matches.length).inject(0) do |sum, i|
            sum += 1 if i == 0
            sum *= 2 if i > 1
            sum
        end
    end

    def to_s
        "Card #{@id}: #{@winning_numbers} | #{@actual_numbers}"
    end
end

result = File.open("../input.txt").readlines.map(&:chomp).inject(0) do |sum, line|
    card = ScratchCard.new(line)
    puts "#{card} - #{card.score}"
    sum += card.score
end

puts result