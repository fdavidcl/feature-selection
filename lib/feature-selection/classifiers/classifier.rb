require 'feature-selection/dataset'

module FeatureSelection
  class Classifier
    def initialize dataset, random: Random.new(CONFIG.random_seed)
      @dataset = dataset
      @rng = random
    end
  end
end
