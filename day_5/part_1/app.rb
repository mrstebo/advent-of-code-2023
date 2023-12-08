class DestinationCategory
    def initialize(*args)
        @destination_range_start = args[0]
        @source_range_start = args[1]
        @range_length = args[2]
    end

    def source_range
        @source_range ||= (@source_range_start..(@source_range_start + @range_length - 1)).to_a
    end

    def destination_range
        @destination_range ||= (@destination_range_start..(@destination_range_start + @range_length - 1)).to_a
    end

    def destination_value_for(source_value)
        return source_value unless source_range.include?(source_value)
        destination_range[source_range.index(source_value)]
    end
end

class Almanac
    def initialize
        @data = File.read('../test.txt')
    end

    def seeds
        @data.split("\n")[0].split(' ').map(&:to_i).select { |n| n > 0 }
    end

    def get_locations_for(seed)
        p ["seed", seed]
        soils = seed_to_soil_map
            .map { |map| map.destination_value_for(seed) }
            .uniq
        p ["soils", soils]
        return soils if soils.empty?

        fertilizers = soils.map do |soil|
            seed_to_fertilizer_map
                .map { |map| map.destination_value_for(soil) }
                .uniq
        end.flatten
        p ["fertilizers", fertilizers]
        return fertilizers if fertilizers.empty?

        waters = fertilizers.map do |fertilizer|
            fertilizer_to_water_map
                .map { |map| map.destination_value_for(fertilizer) }
                .uniq
        end.flatten
        p ["waters", waters]
        return waters if waters.empty?

        lights = waters.map do |water|
            water_to_light_map
                .map { |map| map.destination_value_for(water) }
                .uniq
        end.flatten
        p ["lights", lights]
        return lights if lights.empty?

        temperatures = lights.map do |light|
            light_to_temperature_map
                .map { |map| map.destination_value_for(light) }
                .uniq
        end.flatten
        p ["temperatures", temperatures]
        return temperatures if temperatures.empty?

        humidities = temperatures.map do |temperature|
            temperature_to_humidity_map
                .map { |map| map.destination_value_for(temperature) }
                .uniq
        end.flatten
        p ["humidities", humidities]
        return humidities if humidities.empty?

        locations = humidities.map do |humidity|
            humidity_to_location_map
                .map { |map| map.destination_value_for(humidity) }
                .uniq
        end.flatten
        p ["locations", locations]
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
end

almanac = Almanac.new

# p almanac.seeds
# p almanac.seed_to_soil_map
# p almanac.seed_to_fertilizer_map
# p almanac.fertilizer_to_water_map
# p almanac.water_to_light_map
# p almanac.light_to_temperature_map
# p almanac.temperature_to_humidity_map
# p almanac.humidity_to_location_map
# puts ""

lowest_location = nil
almanac.seeds.each do |seed|
    p [seed, almanac.get_locations_for(seed)]
end

