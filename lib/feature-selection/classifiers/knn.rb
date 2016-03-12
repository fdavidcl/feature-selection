require 'rserve/simpler'
require 'feature-selection/dataset'
require 'matrix' # Needed to pass dataset through R connection

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

      # Prepare variables in R connection
      @r.command "", original: dataset.dataframe, k: k
    end

    def fitness_for features = [0]
      @r >> %Q{
        # Assume the class is the last column
        # Restrict to current features
        features <- c(#{features.join(",")})
        dataset <- original[c(features + 1, length(original))]
        class_col <- length(dataset)

        # Calculate fitness: Proportion of correctly classified instances
        # when leaving them out of the training data
        mean(sapply(seq(1, length(dataset[, 1])), function(instance_index) {
          knn(
            train = dataset[-instance_index, -class_col],
            test = dataset[instance_index, -class_col],
            cl = dataset[-instance_index, class_col],
            k
          ) == dataset[instance_index, class_col] # we may need to set use.all = FALSE
        }))
      }
    end
  end
end
