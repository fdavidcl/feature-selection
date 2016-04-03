#require 'matrix' # Needed to pass dataset through R connection
require "feature-selection/heuristics/heuristic"

module FeatureSelection
  class CKNearest < Classifier
  end
end

require "c_knn"
