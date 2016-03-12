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
        library(parallel)
        library(compiler)

        .fitness <- function(k, dataset, features) {
          # Assume the class is the last column
          # Restrict to current features
          dataset <- dataset[c(features + 1, length(original))]
          class_col_num <- length(dataset)

          no_class <- dataset[-class_col_num]
          class_col <- dataset[[class_col_num]]

          # Calculate fitness: Proportion of correctly classified instances
          # when leaving them out of the training data
          mean(as.numeric(mclapply(seq(1, length(class_col)), function(instance_index) {
            knn(
              train = no_class[-instance_index,],
              test = no_class[instance_index,],
              cl = class_col[-instance_index],
              k
            ) == class_col[instance_index] # we may need to set use.all = FALSE
          })))
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
