require_relative "greedy"

module FeatureSelection
  class RandomizedSFS < SeqForwardSelection
    private
    def select_next
      fitness_list = neighborhood.map{ |_, fitness| fitness }
      threshold = fitness_list.max - CONFIG.grasp[:alpha] * (fitness_list.max - fitness_list.min)

      neighborhood.select do |_, fitness|
        fitness > threshold
      end.sample random: @rng
    end
  end
end
