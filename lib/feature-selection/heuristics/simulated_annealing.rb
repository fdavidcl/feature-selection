require_relative "local_search"

module FeatureSelection
  class SimAnnealing < LocalSearch
    def initialize dataset
      super

      worsening = prob_accept = 0.3
      @initial_temp = worsening * @classifier.fitness_for(@solution) / -Math.log(prob_accept)
      @final_temp = 1e-3
      @max_generated = 10 * @dataset.input_count
      @max_selections = 0.1 * @dataset.input_count
      @num_cooldowns = 15000 / @max_generated
      @cooled = 0
      @temperature = @initial_temp
    end

    private
    def outer_loop
      until cold?
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

        #puts "#{generated_neighbors} neighbors generated, #{selections} selected. Cooling down..."
        cool_down
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
