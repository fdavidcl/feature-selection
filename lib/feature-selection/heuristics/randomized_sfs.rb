require_relative "greedy"

module FeatureSelection
  class RandomizedSFS < SeqForwardSelection
    private
    def select_next
      ranking = neighborhood.sort_by do |_, fitness|
        fitness
      end.reverse!
      threshold = ranking.first[2] + CONFIG.grasp[:alpha] * (ranking.first[2] - ranking.last[2])

      ranking.select! do |_, fitness|
        fitness > threshold
      end

      ranking.sample random: @rng
    end
  end
end
