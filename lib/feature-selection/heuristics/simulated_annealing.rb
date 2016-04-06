require_relative "local_search"

module FeatureSelection
  class SimAnnealing < LocalSearch
    def initialize dataset, debug: false, random: Random.new(CONFIG.random_seed)
      super

      @initial_temp = CONFIG.simulated_annealing[:worsening] * fitness_for(@solution) / -Math.log(CONFIG.simulated_annealing[:prob_accept])
      @final_temp = 1e-3
      @max_generated = CONFIG.simulated_annealing[:max_neighbors_factor] * @dataset.input_count
      @max_selections = CONFIG.simulated_annealing[:max_selections_factor] * @max_generated
      @num_cooldowns = CONFIG.max_evaluations / @max_generated
      @cooled = 0
      @temperature = @initial_temp

      if @debug
        puts @initial_temp
      end
    end

    private
    def outer_loop
      success = true

      until cold? || !success
        generated_neighbors = 0
        selections = 0

        while generated_neighbors < @max_generated && selections < @max_selections
          selected, fitness =
            neighborhood.lazy.take(@max_generated - generated_neighbors).detect do |attempt, fitness|
              generated_neighbors += 1
              difference = fitness - @fitness
              difference > 0 || (difference < 0 && @rng.rand <= Math.exp(difference / @temperature))
            end

          unless selected.nil?
            selections += 1
            self.solution = selected, fitness
          end
        end

        cool_down
        puts "#{generated_neighbors} neighbors generated, #{selections} selected. Cooling down to #{@temperature}" if @debug

        success = false if selections.zero?
      end
    end

    def cool_down
      @beta ||= (@initial_temp - @final_temp) / (@num_cooldowns * @initial_temp * @final_temp)
      @temperature = @temperature / (1 + @beta * @temperature)
      #puts "New temperature: #{@temperature}"
      @cooled += 1
    end

    def cold?
      @cooled >= @num_cooldowns || @temperature <= @final_temp
    end
  end
end
