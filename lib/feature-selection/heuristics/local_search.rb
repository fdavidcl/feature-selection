require "bitarray"
require_relative "heuristic"

class BitArray
  def ones
    each_with_index.select{ |a, _| a.nonzero? }.map(&:last)
  end
end

module FeatureSelection
  class LocalSearch < Heuristic
    def initialize dataset
      super

      @rng = Random.new RANDOM_SEED
      @solution = random_solution
    end

    def run
      # initialize with current solution
      @fitness = @classifier.fitness_for(@solution.ones)
      next_one = [@solution, @fitness]

      while !next_one.nil?
        # Save previous valid solution and find the next
        @solution, @fitness = next_one
        puts "Next solution: #{@solution} with fitness #{@fitness}"
        next_one = select_next
      end

      [@solution, @fitness]
    end

    private
    def neighborhood
      Enumerator.new do |yielder|
        # Randomly generate the neighborhood by flipping each bit in the solution
        (0 ... @solution.length).to_a.shuffle!(random: @rng).each do |f|
          attempt = @solution.clone.toggle_bit(f)

          yielder << [
            attempt,
            @classifier.fitness_for(attempt.ones)
          ]
        end
      end
    end

    def random_solution
      size = @dataset.input_count
      BitArray.new(size).tap do |solution|
        # Method 1: Randomly set each bit to 0 or 1
        (0..size - 1).each do |i|
          solution.set_bit(i) if @rng.rand(2) == 1
        end

        # Method 2: Set a random sample of bits
        # (0 ... size).to_a.sample(@rng.rand(size), random: @rng).each{ |i| solution.set_bit i }
      end
    end
  end
end
