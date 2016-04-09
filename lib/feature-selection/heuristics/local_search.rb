require_relative "heuristic"

module FeatureSelection
  class LocalSearch < Heuristic
    def initialize dataset, debug: false, random: Random.new(CONFIG.random_seed)
      super

      @solution = random_solution
      puts "Initial solution: #{@solution}" if @debug
      @evaluations = 0
      @max_evaluations = CONFIG.max_evaluations
      @best_solution = @solution
    end

    def run
      # initialize with current solution
      @best_fitness = @fitness = fitness_for(@solution)
      outer_loop

      [@best_solution, @best_fitness]
    end

    def solution= new_solution
      @solution, @fitness = new_solution

      if @fitness > @best_fitness
        @best_solution, @best_fitness = @solution, @fitness
        puts "Better solution: #{@best_solution} with fitness #{@best_fitness}" if @debug
      end
    end

    private
    def outer_loop
      basic_local_search
    end

    def basic_local_search
      next_one = [@solution, @fitness]
      until next_one.nil?
        # Save previous valid solution and find the next
        self.solution = next_one
        begin
          next_one = select_next
        rescue ArgumentError
          next_one = nil
        end
      end
    end

    def neighborhood
      Enumerator.new do |yielder|
        # Randomly generate the neighborhood by flipping each bit in the solution
        (0 ... @solution.length).to_a.shuffle!(random: @rng).each do |f|
          attempt = @solution.clone.toggle_bit(f)

          yielder << [
            attempt,
            fitness_for(attempt),
            f
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
