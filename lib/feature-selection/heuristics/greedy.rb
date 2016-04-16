require "bitarray"
require_relative "heuristic"

module FeatureSelection
  class SequentialSelection < Heuristic
    def initialize dataset, forward, debug: false, random: Random.new(CONFIG.random_seed)
      super(dataset, debug: debug, random: random)
      
      @forward = forward
    end

    def run
      @solution = []
      @remaining = [* 0 ... @dataset.input_count]
      @fitness = 0

      improving = true

      while improving do
        attempt, fitness, feature = select_next

        if !fitness.nil? && fitness > @fitness
          puts "Next feature selected: #{feature} with fitness #{fitness}" if @debug
          @solution = attempt
          @remaining.delete feature
          @fitness = fitness
          improving = false if !@forward && @remaining.length == 1
        else
          improving = false
        end
      end

      [
        (@forward ? @solution : @remaining).to_bitarray(@dataset.input_count),
        @fitness
      ]
    end

    private
    def select_next
      neighborhood.max_by do |_, fitness|
        fitness
      end
    end

    def neighborhood
      Enumerator.new do |yielder|
        @remaining.each do |feature|
          attempt = @forward ? @solution + [feature] : @remaining - [feature]

          yielder << [
            attempt,
            fitness_for(attempt.to_bitarray(@dataset.input_count)),
            feature
          ]
        end
      end
    end
  end

  class SeqForwardSelection < SequentialSelection
    def initialize dataset, debug: false, random: Random.new(CONFIG.random_seed)
      super(dataset, true, debug: debug, random: random)
    end
  end

  class SeqBackwardSelection < SequentialSelection
    def initialize dataset, debug: false, random: Random.new(CONFIG.random_seed)
      super(dataset, false, debug: debug, random: random)
    end
  end
end
