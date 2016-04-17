require_relative "heuristic"

module FeatureSelection
  class Genetic < Heuristic
    def initialize dataset, debug: false, random: Random.new(CONFIG.random_seed)
      super

      # initialize population
      @endless_forms = (0 ... CONFIG.genetic[:size]).map{ random_solution }
      @fitness = @population.map{ |solution| [solution, fitness_for(solution)] }.to_h
    end

    def crossover one, other
      len = one.length
      start, stop = [@rnd.rand(0 ... len), @rnd.rand(0 ... len)].sort

      [[one, other], [other, one]].map do |pair|
        pair[0][0 ... start] + pair[1][start ... stop] + pair[0][stop ... len]
      end
    end
  end
end
