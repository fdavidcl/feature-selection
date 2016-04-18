require_relative "genetic"

module FeatureSelection
  class GenerationalGenetic < Genetic
    private
    def generation
      new_population = evolution
      chromosome_len = new_population.first.length

      # Mutation process
      mutated_count = CONFIG.genetic[:generational][:mutation_p] * new_population.length * chromosome_len
      mutated_genes = (0 ... mutated_count).map do
        @rng.rand(0 ... new_population.length * chromosome_len)
      end
      mutated_genes.each do |gene|
        chromosome = gene / chromosome_len
        inner_gene = gene % chromosome_len
        new_population[chromosome].toggle_bit inner_gene
      end

      # Elitism
      previous_best = @endless_forms.max_by{ |c| fitness_for c }
      unless new_population.include? previous_best
        new_worst_i = @endless_forms.each_with_index.min_by{ |c, i| fitness_for c }.last
        new_population[new_worst_i] = previous_best
      end

      new_population
    end

    def evolution
      len = @endless_forms.length
      pair_count = CONFIG.genetic[:generational][:crossover_p] * len / 2

      parents = selection len
      couples = parents.each_slice(2)
      children = couples.take(pair_count).map do |first, second|
        crossover first, second
      end

      (children + couples.drop(pair_count)).flatten
    end
  end
end
