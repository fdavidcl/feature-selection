require_relative "heuristics/heuristic"
require_relative "dataset"

module FeatureSelection
  class Evaluator
    attr_accessor :folds, :repeats

    def initialize folds: 2, repeats: 5
      @folds = folds
      @repeats = repeats
    end

    def evaluate heuristic_class, dataset
      partitions = (0 ... repeats).map{ dataset.partition 2, random: FeatureSelection::RNG }
      results = (partitions + partitions.map(&:reverse)).map do |train, test|
        heuristic = heuristic_class.new(train)
        solution, fitness = heuristic.run
        evaluation = heuristic.classifier.class.new(NUMBER_NEIGHBORS, test).fitness_for(solution)

        [solution, fitness, evaluation]
      end

      [:solution, :training, :test].zip(results.transpose).to_h
    end
  end
end
