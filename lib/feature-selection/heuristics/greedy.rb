require "bitarray"
require_relative "heuristic"

class Array
  def to_bitarray len = max + 1
    BitArray.new(len).tap do |b|
      each { |i| b.set_bit i }
    end
  end
end

module FeatureSelection
  class SequentialSelection < Heuristic
    def initialize dataset, forward = true
      super(dataset)

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
          puts "Next feature selected: #{feature} with fitness #{fitness}"
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
        new_fitness = @classifier.fitness_for(next_attempt)

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
