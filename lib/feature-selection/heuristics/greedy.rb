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
  class SeqForwardSelection < Heuristic
    def initialize dataset
      super

      @solution = []
      @fitness = 0
      @remaining = [* 0 ... @dataset.input_count]
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

      [@solution.to_bitarray(@dataset.input_count), @fitness]
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
