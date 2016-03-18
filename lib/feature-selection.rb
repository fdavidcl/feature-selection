
module FeatureSelection
  RANDOM_SEED = 1
  RNG = Random.new RANDOM_SEED
  NUMBER_NEIGHBORS = 3
end

require "feature-selection/version"
require "feature-selection/classifiers"
require "feature-selection/heuristics"
require "feature-selection/evaluator"
