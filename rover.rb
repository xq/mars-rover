#!/bin/ruby

=begin
This file contains the implementation details to CloudPassages coding test
by Thomas Pastinsky. To run it, execute the file with ruby and provide
an input file, for example:
'ruby roverOO_thomasPastinsky.rb inputFile.txt'
=end

# World destroying errors will be thrown with this exception
class MarsInitializationException < Exception ; end

#
# The grid object implementation for the mars plateau
#
class Grid
	attr_accessor :lower_bounds, :upper_bounds, :rovers

	# Given valid input, creates a new mars grid according to the provided specification as provided by the input
	def initialize(input)
		@lower_bounds = [0, 0]
		@upper_bounds = input.split.map(&:to_i)
		if upper_bounds.any?{|coord| coord <= 0}
		  raise MarsInitializationException.new("Upper grid bounds must be higher than lower grid bounds")
		end
		@rovers = []
	end

	# Keep track of rovers on the grid for collision avoidance
	def add_rover(rover)
		if !checkBounds(rover.position) || rover.position.any?{|coord| coord < 0}
		  raise MarsInitializationException.new("Rovers initial position must not exceed the grid bounds")
		end
		@rovers << rover
	end

	# Checks if a given coordinate contains a rover or not
	def position_empty?(coordinates)
		@rovers.each do |rover|
			return false if rover.position == coordinates
		end
		true
	end

	# Make sure the robot doesn't go astray
	def checkBounds(coordinates)
		if(coordinates[0] > upper_bounds[0])
			return false
		end
		if(coordinates[1] > upper_bounds[1])
			return false
		end
		true
	end

end

#
# The rover object implementation for navigating the mars plateau
#
class Rover
	# Rover has the cardinal directions mapped in robot terms
	COMPASS = { "N" => [0,1], "S" => [0,-1], "W" => [-1,0], "E" => [1,0] }

	# Variables for the rovers positional awareness and orientation
	attr_accessor :position, :direction, :grid

	# Bring the rover up with its location details for navigation
	def initialize(input, grid)
		orientation = input.split
		@position = [orientation[0].to_i, orientation[1].to_i]
		@direction = cardinalToCoordinates(orientation[2])
		@grid = grid
		@grid.add_rover(self)
	end

	# Print out the cardinal representation of a given coordinate
	def cardinalToCoordinates(cardinal)
		COMPASS.each{|key, value| return value if cardinal == key}
	end
	# Print out the cardinal representation of a given coordinate
	def coordinatesToCardinal(coordinates)
		COMPASS.each{|key, value| return key if coordinates == value}
	end

	# Turn the robot left 90 degrees
	def turnL
		@direction = [@direction[1] * -1, @direction[0]]
	end
	# Turn the robot right 90 degrees
	def turnR
		@direction = [@direction[1], @direction[0] * -1]
	end

	# Perform movement to new coordinates
	def move
		potentialX = @position[0] + @direction[0]
		potentialY = @position[1] + @direction[1]
		potentialMove = [potentialX, potentialY]
		unless @grid.checkBounds(potentialMove)
			puts "Unable to move, out of bounds error.\nTrying next processable move.." 
			return false
		end
		if @grid.position_empty?(potentialMove)
			@position[0] = potentialX
			@position[1] = potentialY
		else
			cardinal = coordinatesToCardinal(@direction)
			puts "Unable to move #{cardinal} to #{@position.join(",")} as"\
			     " it is blocked by another rover.\nTrying next prcoessable move.."
			return false
		end
		true
	end

	# Update rover position on grid
	def updatePosition(line)
		local = line.strip.split("")
		local.each do |action|
			case action
			when "M"
				move
			when "L"
				turnL
			when "R"
				turnR
			else
				return puts "Unidentified character: " + action
			end
		end
		cardinal = coordinatesToCardinal(@direction)
		puts "#{@position[0]} #{@position[1]} #{cardinal}"
	end

end

#
# The Mars "world" object. Contains entry points and processing logic
# for the occupation of the Mars world.
#
class Mars
	attr_accessor :line_count, :rover, :grid

	# Initialize objects that will be available throughout the course of the program
	def initialize
		@line_count = 0
		@current_line = nil
		@rover = nil
		@grid = nil
	end

	# The aptly named main entry point for rover exploration on the mars world.
	def invade
		# Parse and process input
		ARGF.each do |line|
			track_current_line(line)
			create_grid if @line_count == 1
			next if @line_count == 1
			spawn_rover if @line_count % 2 == 0
			update_rover if @line_count % 2 == 1
		end

		# Verify we have enough lines to engage movement. Help the user out if not
		if @line_count < 3
			puts "The input must consist of at least 2 lines.\n"\
			     "The first line must be the maximum size of the grid.\n"\
			     "The second line must contain the initial position and orientiation of a rover.\n"\
			     "The third line must contain rover movements.\n"\
			     "For example:\n5 5\n1 2 N\nLMLMLMRM"
		end
	end

	# Spawns a rover given the appropriate location input on the mars grid.
	def spawn_rover
		@rover = Rover.new(@current_line, @grid)
	end

	# Updates a rover given the appropriate movement input on the mars grid.
	def update_rover
		@rover.updatePosition(@current_line)
	end

	# Initializes the Mars grid which defines the available movements on Mars.
	def create_grid
		@grid = Grid.new(@current_line)
	end

	# Keeps track of all input to be processed by the rovers.
	def track_current_line(input)
		@line_count += 1
		@current_line = input
	end

end

# Begin the invasion of Mars by the rovers!
Mars.new.invade

