require_relative "generational"
require_relative "local_search"

module FeatureSelection
  # Metaprogramming exercise here
  def self.Memetic number_generations, population_ratio, prioritize
    Class.new(GenerationalGenetic) do
      include LocalTools

      define_method "run" do
        counter = 0

        until @evaluations >= CONFIG.max_evaluations
          current_best = @endless_forms.max_by{ |c| fitness_for c }
          puts "Best of current population: #{current_best} with fitness #{fitness_for current_best} (#{@evaluations} evaluations)" if @debug

          @endless_forms = generation
          counter += 1
          if counter == number_generations
            amount = population_ratio * @endless_forms.length

            indices = if prioritize
                (0 ... @endless_forms.length).sort_by{ |i| fitness_for @endless_forms[i] }.take(amount)
              else
                (0 ... @endless_forms.length).to_a.sample(amount, random: @rng)
              end

            indices.each do |index|
              next_one = next_first_descent @endless_forms[index], fitness_for(current_best)
              if !next_one.nil?
                @endless_forms[index] = next_one
              end
            end

            counter = 0
          end
        end

        [current_best, fitness_for(current_best)]
      end
    end
  end
end
