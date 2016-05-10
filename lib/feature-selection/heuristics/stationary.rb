require_relative "genetic"

module FeatureSelection
  class StationaryGenetic < Genetic
    private
    def generation
      # Tournament select 2 parents, get children by the crossover operator
      first, second = crossover *(selection 2)

      # Mutation process
      (0 ... first.length).each do |i|
        first.toggle_bit i  if @rng.rand < CONFIG.genetic[:stationary][:mutation_p]
        second.toggle_bit i if @rng.rand < CONFIG.genetic[:stationary][:mutation_p]
      end

      first, second = second, first if fitness_for(first) < fitness_for(second)

      # Replacement scheme
      worst, worst_i = @endless_forms.each_with_index.min_by do |c, i|
        fitness_for c
      end
      sworst, sworst_i = @endless_forms.each_with_index.min_by do |c, i|
        (i == worst_i) ? 1 : (fitness_for c)
      end

      if fitness_for(first) > fitness_for(worst)
        if fitness_for(second) > fitness_for(worst)
          @endless_forms[worst_i] = second

          if fitness_for(first) > fitness_for(sworst)
            @endless_forms[sworst_i] = first
          else
            # Prioritize the best of both children
            @endless_forms[worst_i] = first
          end
        else
          @endless_forms[worst_i] = first
        end
      end

      @endless_forms
    end
  end
end
