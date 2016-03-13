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
        library(compiler)

        .fitness <- function(k, dataset, features) {
          # Assume the class is the last column
          # Restrict to current features
          dataset <- dataset[c(features + 1, length(dataset))]
          class_col_num <- length(dataset)

          no_class <- dataset[-class_col_num]
          class_col <- dataset[[class_col_num]]

          mean(knn.cv(no_class, class_col, k = 3) == class_col)
        }
        fitness <- cmpfun(.fitness)

      }
      # @rng = Random.new 1

      # Prepare variables in R connection
      @r.command "", original: dataset.dataframe, k: k
    end

    def fitness_for features = [0]
      @r >> "fitness(k, original, c(#{features.join(",")}))"
    end
  end
end
