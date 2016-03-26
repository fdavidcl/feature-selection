require "bitarray"
require_relative "heuristic"

module FeatureSelection
  class SequentialSelection < Heuristic
    def initialize dataset, forward, debug: false
      super(dataset, debug: debug)

      @solution = []
      @fitness = 0
      @remaining = [* 0 ... @dataset.input_count]
      @forward = forward
    end

    def run
      improving = true

      while improving do
        feature, fitness = select_next

        if feature
          puts "Next feature selected: #{feature} with fitness #{fitness}" if @debug
          @solution << feature
          @remaining.delete feature
          @fitness = fitness
        else
          improving = false
        end
      end

      [
        (@forward ? @solution : @remaining).to_bitarray(@dataset.input_count),
        @fitness
      ]
    end

    private
    def select_next
      @remaining.reduce([false, @fitness]) do |(best, fitness), feature|
        next_attempt = @forward ? @solution + [feature] : @remaining - [feature]
        # Evaluate current feature
        new_fitness = @classifier.fitness_for(next_attempt.to_bitarray)

        # Choose the best feature
        if new_fitness > fitness
          [feature, new_fitness]
        else
          [best, fitness]
        end
      end
    end
  end

  class SeqForwardSelection < SequentialSelection
    def initialize dataset
      super(dataset, true)
    end
  end

  class SeqBackwardSelection < SequentialSelection
    def initialize dataset
      super(dataset, false)
    end
  end
end
