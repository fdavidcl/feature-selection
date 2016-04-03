#require 'matrix' # Needed to pass dataset through R connection
require "feature-selection/heuristics/heuristic"

module FeatureSelection
  class CKNearest < Classifier
    def initialize k, dataset, random: Random.new(CONFIG.random_seed)
      super(dataset, random: random)

      @k = k
    end

    def fitness_for features
      leaveoneout(
        @k,
        @dataset.instances,
        @dataset.classes,
        @dataset.class_count,
        features.to_a,
        @dataset.numeric_attrs,
        @rng
      )
    end
  end
end

require "c_knn"
