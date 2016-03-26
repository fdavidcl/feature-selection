require_relative "local_search"

module FeatureSelection
  class BasicTabuSearch < LocalSearch
    def initialize dataset, debug: false, random: Random.new(RANDOM_SEED)
      super

      @tabu_list = []
      @max_tabu_length = @solution.length/3
      @max_generated = 30
      @num_iterations = 500
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
      @tabu_list.unshift index
      @tabu_list.pop unless @tabu_list.length < @max_tabu_length
      puts @tabu_list.to_s if @debug
    end

    def select_next
      neighborhood.take(@max_generated).max_by do |attempt, fitness, index|
        if !@tabu_list.include?(index) || fitness > @fitness
          fitness
        else
          0
        end
      end
    end
  end
end
