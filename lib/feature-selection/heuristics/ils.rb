require_relative "local_search"

module FeatureSelection
  class IterativeLocalSearch < FirstDescent
    def initialize dataset, debug: false, random: Random.new(CONFIG.random_seed)
      super

      @switched_features = CONFIG.ils[:mutation_ratio] * @solution.length
    end

    private
    def outer_loop
      basic_local_search
      CONFIG.ils[:mutated_count].times do
        mutated = mutate @solution
        puts "Mutated solution: #{mutated}" if @debug
        self.solution = [mutated, fitness_for(mutated)]
        basic_local_search
        # Election criteria: choose the best solution
        # (already implemented in LocalSearch#solution=)
      end
    end

    def mutate solution
      solution.tap do |mutated|
        (0 ... mutated.length).to_a.sample(@switched_features, random: @rng).each do |i|
          mutated.toggle_bit i
        end
      end
    end
  end
end
