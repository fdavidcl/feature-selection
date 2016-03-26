require "bitarray"
require_relative "monotonic_search"

module FeatureSelection
  class LocalSearch < MonotonicSearch
    def initialize dataset, debug: false
      super

      @best_solution = @solution
    end

    def run
      # initialize with current solution
      @best_fitness = @fitness = @classifier.fitness_for(@solution)
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
  end
end
