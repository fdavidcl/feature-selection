require 'rserve/simpler'
require 'feature-selection/dataset'
require 'matrix' # Needed to pass dataset through R connection

module FeatureSelection
  class KNearest < Classifier
    def initialize k, dataset
      @r = Rserve::Simpler.new
      @r.command %Q{
        if (!("class" %in% installed.packages()[, "Package"]))
          install.packages("class")
        library(class)
        library(compiler)

        set.seed(random_seed)

        inputs <- seq(1, length(dataset))[-class_col_num]
        class_col <- dataset[[class_col_num]]

        .fitness <- function(features) {
          # Assume the class is the last column
          # Restrict to current features
          no_class <- dataset[inputs[features]]
          mean(knn.cv(no_class, class_col, k = 3) == class_col)
        }
        fitness <- cmpfun(.fitness)

      },
      {
        random_seed: RANDOM_SEED,
        dataset: dataset.dataframe,
        class_col_num: dataset.class_col + 1,
        k: k
      }
    end

    def fitness_for features
      @r >> "fitness(c(#{features.join(",")} + 1))"
    end
  end
end
