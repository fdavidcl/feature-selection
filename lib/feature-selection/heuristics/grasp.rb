require_relative "local_search"
require_relative "randomized_sfs"

module FeatureSelection
  class Grasp < FirstDescent
    def initialize dataset, debug: false, random: Random.new(CONFIG.random_seed)
      super

      @initial_generator = RandomizedSFS.new @dataset, debug: @debug, random: @rng
    end

    private
    def outer_loop
      CONFIG.grasp[:initial].times do
        self.solution = @initial_generator.run
        basic_local_search
      end
    end
  end
end
