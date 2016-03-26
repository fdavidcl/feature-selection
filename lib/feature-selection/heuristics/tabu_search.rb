require_relative "basic_tabu_search"

module FeatureSelection
  class TabuSearch < BasicTabuSearch
    def initialize dataset, debug: false
      super

      @frequencies = Array.new @solution.length, 0
      @solution_count = 0
      @initial_countdown = 10
    end

    def solution= new_solution
      super

      @frequencies.map
      @solution_count += 1
    end

    private
    def outer_loop
      long_term
    end

    def long_term
      countdown = @initial_countdown
      remaining = @num_iterations

      while remaining > 0
        prev_best = @best_fitness
        short_term
        remaining -= 1
        countdown = (@fitness > prev_best) ? @initial_countdown : countdown - 1

        if countdown == 0 && remaining > 0
          reinitialize
          countdown = @initial_countdown
        end
      end
    end

    def reinitialize
      @tabu_list = []
      @max_tabu_length = @max_tabu_length * [0.5, 1.5].sample(random: @rng)

      new_s =
        case (0 .. 3).to_a.sample(random: @rng)
        when (0 .. 1)
          diverse_solution
        when 2
          random_solution
        when 3
          @best_solution
        end

      self.solution = new_s, @classifier.fitness_for(new_s)
    end

    def diverse_solution
      (0 ... @dataset.input_count).select do |feature|
        @rng.rand < 1 - @frequencies[feature]/@solution_count
      end.to_bitarray
    end
  end
end
