require "bitarray"
require_relative "heuristic"

module FeatureSelection
  class NoSelection < Heuristic
    def initialize dataset, debug: false
      super

      @solution = BitArray.new(@dataset.input_count).tap{ |b| b.set_all_bits }
    end
    def run
      [
        @solution,
        @classifier.fitness_for(@solution)
      ]
    end
  end
end
