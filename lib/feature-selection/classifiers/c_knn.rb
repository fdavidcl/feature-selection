#require 'matrix' # Needed to pass dataset through R connection
require "feature-selection/heuristics/heuristic"

module FeatureSelection
  class CKNearest < Classifier
    def initialize k, dataset, random: Random.new(CONFIG.random_seed)
      super(dataset, random: random)

      @k = k
    end

    def fitness_for features
      puts @dataset.instances.to_s
      leaveoneout(
        @k,
        @dataset.instances,
        @dataset.classes,
        features.to_a,
        @rng
      )
    end
  end
end

require "c_knn"
