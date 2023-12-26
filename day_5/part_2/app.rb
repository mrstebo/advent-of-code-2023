class DestinationCategory
    def initialize(*args)
        @destination_range_start = args[0]
        @source_range_start = args[1]
        @range_length = args[2]
    end

    attr_reader :destination_range_start, :source_range_start, :range_length
end

class Almanac
    def initialize
        @data = File.read('../input.txt')
    end

    def seed_ranges
        @data
            .split("\n")[0]
            .split(' ')
            .map(&:to_i)
            .select { |n| n > 0 }
            .each_slice(2)
            .map { |start, length| { start: start, length: length } }
    end

    def walk(value, range, name = nil)
        if name.nil?
            name = get_maps.keys.first
        end

        # Get the map we need to use
        item = get_maps[name]

        # If we don't have a map for this name, we've reached the end
        if item.nil?
            # puts "End of the line: #{value} (#{range}) [#{name}]"
            return [value, range]
        end

        # Find the range item where we intersect
        range_item = item[:map].find do |i|
            i.source_range_start <= value && i.source_range_start + i.range_length > value
        end

        # If we don't have a range for this, then we need to return the value itself
        if range_item.nil?
            return walk(value, 1, item[:to])
        end

        diff = value - range_item.source_range_start
        new_value = range_item.destination_range_start + diff
        new_range = range_item.range_length - diff

        # puts "#{name}: #{value} -> #{new_value} (#{range_item.destination_range_start} + #{diff})"
        # puts "  #{range} -> #{new_range} (#{range_item.range_length} - #{diff})"
        # sleep 1
        walk(new_value, [range, new_range].min, item[:to])
    end

    private

    def get_maps
        unless @maps
            @maps = Hash.new

            @data.split("\n").each do |line|
                if line.empty?
                    next
                elsif line.include?('to')
                    from, to = line.match(/(\w+)-to-(\w+)/).captures
                    @maps[from] = { to: to, map: [] }
                elsif @maps.keys.length > 0
                    @maps[@maps.keys.last][:map] << DestinationCategory.new(*line.split(' ').map(&:to_i))
                end
            end
        end
        @maps
    end
end

almanac = Almanac.new

threads = []
locations = {}
almanac.seed_ranges.each do |range|
    locations[range] = nil

    threads << Thread.new do
        puts "Processing #{range}"
        remaining = range[:length]
        start = range[:start]
        lowest_location = nil

        while remaining > 0
            location, consumed = almanac.walk(start, remaining)
            lowest_location = location if lowest_location.nil? || location < lowest_location

            start += consumed
            remaining -= consumed

            puts "[#{range}]location: #{location}, consumed: #{consumed}, remaining: #{remaining}" if consumed > 1
        end

        puts "Finished #{range}"

        locations[range] = lowest_location
    end
end
threads.each(&:join)

p locations
puts "\n"
puts locations.values.min
