require_relative "heuristic"

module FeatureSelection
  # Abstract the basics of a local search in a module so we can hybridize other
  # techniques later
  module LocalTools
    def neighborhood solution = nil
      solution ||= @solution
      Enumerator.new do |yielder|
        # Randomly generate the neighborhood by flipping each bit in the solution
        (0 ... solution.length).to_a.shuffle!(random: @rng).each do |f|
          attempt = solution.clone.toggle_bit(f)

          yielder << [
            attempt,
            fitness_for(attempt),
            f
          ]
        end
      end
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

    # First descent selection
    def next_first_descent solution = nil, limit = nil
      return nil if @evaluations >= CONFIG.max_evaluations
      solution ||= @solution
      limit ||= @fitness
      neighborhood(solution).lazy.take(CONFIG.max_evaluations - @evaluations).detect do |attempt, fitness|
        fitness > limit
      end
    end

    # Max descent selection
    def next_max_descent solution = nil, limit = nil
      return nil if @evaluations >= CONFIG.max_evaluations
      solution ||= @solution
      limit ||= @fitness
      neighbor, fitness = neighborhood(solution).lazy.take(CONFIG.max_evaluations - @evaluations).max_by &:last
      [neighbor, fitness] if !neighbor.nil? && fitness > limit # returns nil otherwise
    end
  end

  # Build a class wrapper around the local search module so we can use it as an heuristic
  class LocalSearch < Heuristic
    include LocalTools

    def initialize dataset, debug: false, random: Random.new(CONFIG.random_seed)
      super

      @solution = random_solution
      puts "Initial solution: #{@solution}" if @debug
      @evaluations = 0
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
  end

  # Specialized classes for each kind of selection
  class MaximumDescent < LocalSearch
    alias_method :select_next, :next_max_descent
  end

  class FirstDescent < LocalSearch
    alias_method :select_next, :next_first_descent
  end
end
