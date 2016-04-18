require_relative "genetic"

module FeatureSelection
  class StationaryGenetic < Genetic
    private
    def generation
      best_child, worst_child = evolution
      chromosome_len = new_population.first.length

      # Mutation process
      mutated_count = CONFIG.genetic[:generational][:mutation_p] * new_population.length * chromosome_len
      mutated_genes = (0 ... mutated_count).map do
        @rng.rand(0 ... new_population.length * chromosome_len)
      end
      mutated_genes.each do |gene|
        chromosome = gene / chromosome_len
        inner_gene = gene % chromosome_len
        @endless_forms[chromosome].toggle_bit inner_gene
      end

      ## MISSING: Possibly mutate children (why?)
      # Maybe we want to mutate the population *before* generating children?

      # Replacement scheme
      worst, worst_i = @endless_forms.each_with_index.min_by{ |c, i| fitness_for c }
      second, second_i = @endless_forms.each_with_index.min_by{ |c, i| i == worst_i ? 1 : fitness_for c }

      if fitness_for best_child > fitness_for worst
        if fitness_for worst_child > fitness_for worst
          @endless_forms[worst_i] = worst_child

          if fitness_for best_child > fitness_for second
            @endless_forms[second_i] = best_child
          else
            # We would want to keep the best child, right?
            @endless_forms[worst_i] = best_child
          end
        else
          @endless_forms[worst_i] = best_child
        end
      end

      @endless_forms
    end

    def evolution
      (crossover selection 2).sort_by{ |c| fitness_for c }
    end
  end
end
