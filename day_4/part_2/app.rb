class ScratchCard
    def initialize(line)
        @id = line.match(/^Card\s+(\d+):/)[1].to_i
        @winning_numbers = line.split(":")[1].split("|")[0].split(" ").map(&:to_i)
        @actual_numbers = line.split(":")[1].split("|")[1].split(" ").map(&:to_i)
    end

    attr_reader :id, :winning_numbers, :actual_numbers

    def matches
        @winning_numbers & @actual_numbers
    end

    def copies_from(data, start_index, mapped_counts = {})
        return [] if matches.length == 0

        copies = []
        data[start_index..start_index + matches.length - 1].each_with_index do |line, index|
            copy = ScratchCard.new(line)

            mapped_counts[copy.id] ||= 0
            mapped_counts[copy.id] += 1

            copies << copy
            copies += copy.copies_from(data, start_index + index + 1, mapped_counts)
        end
        copies
    end

    def to_s
        "Card #{@id}: #{@winning_numbers} | #{@actual_numbers}"
    end
end

# I am using this in other methods, so I am keeping it here
data = File.open("../input.txt").readlines.map(&:chomp)

# For debugging purposes
mapped_counts = {}

result = data.each_with_index.inject(0) do |sum, (line, index)|
    card = ScratchCard.new(line)

    # Adding logging, because this takes quite a while to run...
    puts "Processing card #{card.id}"

    # I wanted to check that we got the correct number of matches, specifically when using the test input
    mapped_counts[card.id] ||= 0
    mapped_counts[card.id] += 1

    # We always have at least one of these cards
    sum += 1

    # Use this recursive method to get all the next copies of this card (bad naming, I know)
    copies = card.copies_from(data, index + 1, mapped_counts)

    # Add the number of copies to the sum
    sum += copies.length
    
    sum
end

p mapped_counts

puts result