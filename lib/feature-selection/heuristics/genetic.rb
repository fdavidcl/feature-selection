require_relative "heuristic"

module FeatureSelection
  class Genetic < Heuristic
    def initialize dataset, debug: false, random: Random.new(CONFIG.random_seed)
      super

      # initialize population
      @endless_forms = (0 ... CONFIG.genetic[:size]).map{ random_solution }
      @fitness = {}
    end

    def run
      current_best = @endless_forms.max_by{ |c| fitness_for c }

      until @evaluations >= CONFIG.max_evaluations
        puts "Best of current population: #{current_best} with fitness #{fitness_for current_best} (#{@evaluations} evaluations)" if @debug
        @endless_forms = generation
        # unnecessary calculation here but for debugging purposes
        current_best = @endless_forms.max_by{ |c| fitness_for c }
      end

      [current_best, fitness_for(current_best)]
    end

    private
    def crossover first, second
      len = first.length
      start, stop = [@rng.rand(0 ... len), @rng.rand(0 ... len)].sort

      [
        second[0 ... start] +  first[start ... stop] + second[stop ... len],
         first[0 ... start] + second[start ... stop] +  first[stop ... len]
      ]
    end

    def selection len
      (0 ... len).map do
        first, second = @endless_forms.sample 2, random: @rng
        if fitness_for(first) > fitness_for(second)
          first
        else
          second
        end
      end
    end

    def mutate solution
      solution.toggle_bit @rng.rand(0 ... solution.length)
    end

    def fitness_for solution
      # Prevent repeated evaluations
      @fitness[solution] ||= super
    end
  end
end
