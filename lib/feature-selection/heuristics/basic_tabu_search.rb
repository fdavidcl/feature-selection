require_relative "local_search"

module FeatureSelection
  class BasicTabuSearch < LocalSearch
    def initialize dataset, debug: false, random: Random.new(CONFIG.random_seed)
      super

      @tabu_list = []
      @max_tabu_length = @solution.length/3
      @max_generated = CONFIG.tabu_search[:num_neighbors]
      @num_iterations = CONFIG.max_evaluations / @max_generated
    end

    private
    def outer_loop
      @num_iterations.times do
        short_term
      end
    end

    def short_term
      solution, fitness, index = select_next
      self.solution = [solution, fitness]

      # Delete movement if it's already in the tabu list
      @tabu_list.delete index
      # Add movement to the front of the list
      @tabu_list.unshift index
      # Remove elements from the list
      @tabu_list.pop unless @tabu_list.length < @max_tabu_length
      puts @tabu_list.to_s if @debug
    end

    def select_next
      # Select the non-tabu neighbor with highest fitness (or a tabu neighbor
      # if its fitness is higher than the global)
      neighborhood.take(@max_generated).max_by do |attempt, fitness, index|
        if fitness > @best_fitness || !@tabu_list.include?(index)
          fitness
        else
          0
        end
      end
    end
  end
end
