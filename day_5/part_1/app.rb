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
        @data = File.read('../input.txt')
    end

    def seeds
        @data.split("\n")[0].split(' ').map(&:to_i).select { |n| n > 0 }
    end

    def get_locations_for(seed)
        soils = get_mappings_for(seed, seed_to_soil_map)
        return soils if soils.empty?

        fertilizers = soils.map do |soil|
            get_mappings_for(soil, seed_to_fertilizer_map)
        end.flatten
        return fertilizers if fertilizers.empty?

        waters = fertilizers.map do |fertilizer|
            get_mappings_for(fertilizer, fertilizer_to_water_map)
        end.flatten
        return waters if waters.empty?

        lights = waters.map do |water|
            get_mappings_for(water, water_to_light_map)
        end.flatten
        return lights if lights.empty?

        temperatures = lights.map do |light|
            get_mappings_for(light, light_to_temperature_map)
        end.flatten
        return temperatures if temperatures.empty?

        humidities = temperatures.map do |temperature|
            get_mappings_for(temperature, temperature_to_humidity_map)
        end.flatten
        return humidities if humidities.empty?

        locations = humidities.map do |humidity|
            get_mappings_for(humidity, humidity_to_location_map)
        end.flatten
        return locations if locations.empty?

        locations
    end

    private

    def seed_to_soil_map
        unless @seed_to_soil_map
            @seed_to_soil_map = get_map_rows_for('seed-to-soil')
        end
        @seed_to_soil_map
    end

    def seed_to_fertilizer_map
        unless @seed_to_fertilizer_map
            @seed_to_fertilizer_map = get_map_rows_for('soil-to-fertilizer')
        end
        @seed_to_fertilizer_map
    end

    def fertilizer_to_water_map
        unless @fertilizer_to_water_map
            @fertilizer_to_water_map = get_map_rows_for('fertilizer-to-water')
        end
        @fertilizer_to_water_map
    end

    def water_to_light_map
        unless @water_to_light_map
            @water_to_light_map = get_map_rows_for('water-to-light')
        end
        @water_to_light_map
    end

    def light_to_temperature_map
        unless @light_to_temperature_map
            @light_to_temperature_map = get_map_rows_for('light-to-temperature')
        end
        @light_to_temperature_map
    end

    def temperature_to_humidity_map
        unless @temperature_to_humidity_map
            @temperature_to_humidity_map = get_map_rows_for('temperature-to-humidity')
        end
        @temperature_to_humidity_map
    end

    def humidity_to_location_map
        unless @humidity_to_location_map
            @humidity_to_location_map = get_map_rows_for('humidity-to-location')
        end
        @humidity_to_location_map
    end

    def get_map_rows_for(name)
        rows = @data.split("\n")
        index = rows.index { |row| row.include?(name) }
        rows = rows[index+1..-1]
        last_index = rows.index { |row| row.empty? } || rows.length
        rows[0..last_index-1]
            .map { |row| row.split(' ').map(&:to_i) }
            .map { |row| DestinationCategory.new(*row) }
    end

    def get_mappings_for(seed, mapping)
        results = mapping
            .map { |map| map.destination_value_for(seed) }
            .uniq

        # If the results contain anything other than the seed value, then we need to remove the seed value
        # from the results.
        if results.length > 1 && results.include?(seed)
            results.delete(seed)
        end

        results
    end
end

almanac = Almanac.new

lowest_location = nil
almanac.seeds.each do |seed|
    locations = almanac.get_locations_for(seed)
    lowest_location = locations.min if lowest_location.nil? || locations.min < lowest_location
end

puts lowest_location
