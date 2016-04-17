require_relative "heuristic"

module FeatureSelection
  class Genetic < Heuristic
    def initialize dataset, debug: false, random: Random.new(CONFIG.random_seed)
      super

      # initialize population
      @population = (0 ... CONFIG.genetic[:size]).map{ random_solution }
      @fitness = @population.map{ |solution| [solution, fitness_for(solution)] }.to_h
    end
  end
end
