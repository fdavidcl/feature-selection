require 'rserve/simpler'
require 'matrix' # Needed to pass dataset through R connection
require "feature-selection/heuristics/heuristic"

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
          # Restrict to current features
          mean(knn.cv(dataset[inputs[features]], class_col, k = 3) == class_col)
        }
        fitness <- cmpfun(.fitness)

      },
      {
        random_seed: CONFIG.random_seed,
        dataset: dataset.dataframe,
        class_col_num: dataset.class_col + 1,
        k: k
      }

      @cache = {}
    end

    def fitness_for features
      @r >> "fitness(c(#{features.ones.join(",")} + 1))"
    end
  end
end
