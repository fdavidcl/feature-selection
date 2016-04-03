require "bitarray"
require_relative "monotonic_search"

module FeatureSelection
  class LocalSearch < MonotonicSearch
    def initialize dataset, debug: false, random: Random.new(CONFIG.random_seed)
      super

      @best_solution = @solution
    end

    def run
      # initialize with current solution
      @best_fitness = @fitness = fitness_for(@solution)
      outer_loop

      [@best_solution, @best_fitness]
    end

    def solution= new_solution
      super

      if @fitness > @best_fitness
        @best_solution, @best_fitness = @solution, @fitness
        puts "Better solution: #{@best_solution} with fitness #{@best_fitness}" if @debug
      end
    end
  end
end
