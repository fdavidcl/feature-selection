require_relative "heuristics/heuristic"
require_relative "dataset"

module FeatureSelection
  class Evaluator
    attr_accessor :folds, :repeats

    def initialize folds: 2, repeats: 5
      @folds = folds
      @repeats = repeats
      @rng = Random.new(RANDOM_SEED)
      @seeds = (0 ... folds * repeats).map{ |i| @rng.rand(1 .. 13370000) }
      puts "Evaluator object using seeds #{@seeds.join ", "}."
    end

    def evaluate heuristic_class, dataset, csv: false
      partitions = (0 ... repeats).map{ dataset.partition @folds, random: FeatureSelection::RNG }
      results = partitions.zip(partitions.map(&:reverse)).flatten(1).map.each_with_index do |(train, test), index|
        heuristic = heuristic_class.new(train, random: Random.new(@seeds[index]))
        start = Time.now
        solution, fitness = heuristic.run
        finish = Time.now
        evaluation = heuristic.classifier.class.new(NUMBER_NEIGHBORS, test).fitness_for(solution)
        reduction = solution.count(0).to_f/solution.length

        [solution, fitness, evaluation, reduction, finish - start]
      end

      names = [:solution, :training, :test, :reduction, :time]

      if csv
        ([names] + results).map{ |row| row.join ", " }.join("\n")
      else
        names.zip(results.transpose).to_h
      end
    end
  end
end
