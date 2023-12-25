class DestinationCategory
    def initialize(*args)
        @destination_range_start = args[0]
        @source_range_start = args[1]
        @range_length = args[2]
    end

    def source_range
        @source_range = [@source_range_start, @source_range_start + @range_length - 1]
    end

    def destination_range
        @destination_range = [@destination_range_start, @destination_range_start + @range_length - 1]
    end

    def destination_value_for(source_value)
        return destination_range[0] + (source_value - source_range[0]) if source_value >= source_range[0] && source_value <= source_range[1]

        source_value
    end
end

class Almanac
    def initialize
        @data = File.read('../test.txt')
    end

    def seeds
        @data.split("\n")[0].split(' ').map(&:to_i).select { |n| n > 0 }
    end

    def seed_ranges
        @data
            .split("\n")[0]
            .split(' ')
            .map(&:to_i)
            .select { |n| n > 0 }
            .each_slice(2)
            .map { |start, length| [start, start + length - 1] }
            .sort { |a, b| b[0] <=> a[0] }
    end

    def walk(value, range, name = nil)
        if name.nil?
            return walk(value, range, create_maps.keys.first)
        end
        
        item = create_maps[name]

        if item.nil?
            puts "Found #{value} in #{name}"
            return
        end

        range_item = item[:map].find { |i| i.source_range[0] <= value && i.source_range[1] >= value }

        if range_item.nil?
            puts "Could not find #{value} in #{name}"
            return walk(value, 1, item[:to])
        end

        puts "Found #{value} in #{name} (#{range_item.source_range} -> #{range_item.destination_range})"
        walk(range_item.destination_value_for(value), range, item[:to])
    end

    private

    def create_maps
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

# almanac.seed_ranges.each do |range|
#     almanac.walk(range[0], range)
# end

almanac.seeds.each do |seed|
    almanac.walk(seed, 1)
end
