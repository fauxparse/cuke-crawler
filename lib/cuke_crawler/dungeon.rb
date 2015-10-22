require "pleasant_lawyer"
require "active_support/inflector"

module CukeCrawler
  class Dungeon
    attr_reader :name, :options

    def initialize(name = nil, options = {})
      @name = (name || PleasantLawyer.number_to_words(0).join(" ")).titleize
      @random = Random.new(PleasantLawyer.convert(@name.downcase))
      @options = options
      @locations = generate_maze

      boss = @locations.select { |location| location.monster.present? }.first
      boss.monster.loot = GoldenCucumber.new
    end

    def entrance
      @entrance ||= @locations[(height - 1) * width + (width / 2).floor]
    end

    def goal
      @goal ||= random_location_that_isnt(entrance)
    end

    def map
      Map.new(width, height, @locations, entrance: entrance, goal: goal).to_s
    end

    def self.generate(seed)
      self.new(seed)
    end

    def description
      "the eerie #{name} dungeon.
        It's scary and you wonder if you can make it out alive
        and not covered with spiders"
    end

    private

    def new_location
      Location.new(@random.rand(LARGE_NUMBER), self)
    end

    def generate_maze
      locations = coordinates.map { new_location }
      add_exits_to(locations)
    end

    def add_exits_to(locations)
      mapped = [[0, 0]]

      while mapped.length < locations.length
        candidates = mapped.each.with_object([]) do |(x, y), walls|
          walls << [x, y, :north] if y > 1 && !mapped.include?([x, y - 1])
          walls << [x, y, :south] if y < height - 1 && !mapped.include?([x, y + 1])
          walls << [x, y, :west] if x > 1 && !mapped.include?([x - 1, y])
          walls << [x, y, :east] if x < width - 1 && !mapped.include?([x + 1, y])
        end

        x, y, direction = candidates[@random.rand(candidates.length)]
        origin = locations[y * width + x]
        connection = false
        if direction == :north
          destination = locations[(y - 1) * width + x]
          connection = Connection.new(north: destination, south: origin)
          mapped << [x, y - 1]
        elsif direction == :south
          destination = locations[(y + 1) * width + x]
          connection = Connection.new(south: destination, north: origin)
          mapped << [x, y + 1]
        elsif direction == :west
          destination = locations[y * width + x - 1]
          connection = Connection.new(west: destination, east: origin)
          mapped << [x - 1, y]
        elsif direction == :east
          destination = locations[y * width + x + 1]
          connection = Connection.new(east: destination, west: origin)
          mapped << [x + 1, y]
        end
        origin.add_connection(connection)
        destination.add_connection(connection)
      end

      locations
    end

    def width
      options[:width] || 3
    end

    def height
      options[:height] || 3
    end

    def coordinates
      (0...width).to_a.product((0...height).to_a)
    end

    def random_location_that_isnt(start)
      location = start
      while location == start
        location = @locations[@random.rand(@locations.length)]
      end
      location
    end
  end
end
