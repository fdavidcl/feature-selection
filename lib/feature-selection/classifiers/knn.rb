require 'rserve/simpler'
require 'feature-selection/dataset'

module FeatureSelection
  class KNearest < Classifier
    def initialize k, dataset
      @r = Rserve::Simpler.new
      @r >> %Q{
        if (!("class" %in% installed.packages()[, "Package"]))
          install.packages("class")
        library(class)
      }
      # @rng = Random.new 1
      @dataset = dataset
      @k = k
    end

    def fitness_for features = [0]
      @r.converse %Q{
        # Assume the class is the last column
        # Restrict to current features
        dataset <- dataset[c(features + 1, length(dataset))]
        class_col <- length(dataset)

        # Calculate fitness: Proportion of correctly classified instances
        # when leaving them out of the training data
        mean(sapply(seq(1, length(dataset[, 1])), function(instance_index) {
          train <- dataset[-instance_index, -class_col]
          test <- dataset[instance_index, -class_col]
          cl <- dataset[-instance_index, class_col]

          knn(train, test, cl, k) == dataset[instance_index, class_col] # we may need to set use.all = FALSE
        }))
      }, dataset: @dataset.dataframe, k: @k, features: features
    end
  end
end
