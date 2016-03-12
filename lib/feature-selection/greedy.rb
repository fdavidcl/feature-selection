require_relative "heuristic"

module FeatureSelection
  class SeqForwardSelection < Heuristic
    def initialize dataset
      super

      @solution = []
      @fitness = 0
      @remaining = (0 ... @dataset.num_features).to_a
    end

    def run
      improving = true

      while improving do
        feature, fitness = select_next
        puts "Next feature selected: #{feature} with fitness #{fitness}"

        if feature
          @solution << feature
          @remaining.delete feature
          @fitness = fitness
        else
          improving = false
        end
      end

      [@solution, @fitness]
    end

    private
    def select_next
      @remaining.reduce([false, @fitness]) do |(best, fitness), feature|
        # Evaluate current feature
        new_fitness = @classifier.fitness_for(@solution + [feature])

        # Choose the best feature
        if new_fitness > fitness
          [feature, new_fitness]
        else
          [best, fitness]
        end
      end
    end
  end
end
