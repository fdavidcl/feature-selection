#!/usr/bin/env ruby
require 'ruby-prof'
require "bundler/setup"
require "feature-selection"

arr = FeatureSelection::Dataset.read_arff("../../arrhythmia.arff")
mlibras = FeatureSelection::Dataset.read_arff("../../movement_libras.arff")
wdbc = FeatureSelection::Dataset.read_arff("../../wdbc.arff", 0)
iris = FeatureSelection::Dataset.data("iris")

arr.tap do |dataset|
  puts "Using #{dataset}."

  # result = RubyProf.profile do
  # partitions = (1..5).map{ dataset.partition 2, random: FeatureSelection::RNG }
  # end

  # Falta correr el kNN directamente sobre el dataset

  heuristics = {
    "No selection (kNN with all features)" => FeatureSelection::NoSelection,
    #"Sequential Forward Selection" => FeatureSelection::SeqForwardSelection,
    #"Sequential Backward Selection" => FeatureSelection::SeqBackwardSelection,
    #"First-descent Local Search" => FeatureSelection::FirstDescent,
    #"Maximum-descent Local Search" => FeatureSelection::MaximumDescent,
    #"Simulated Annealing" => FeatureSelection::SimAnnealing,
    #"Basic Tabu Search" => FeatureSelection::BasicTabuSearch,
    "Complete Tabu Search" => FeatureSelection::TabuSearch
  }

  ev = FeatureSelection::Evaluator.new folds: 2, repeats: 1

  # profile the code
  #result = RubyProf.profile do
  heuristics.each do |name, heuristic|
    puts "", "-" * 80, "|#{name.center(78)}|", "-" * 80
    t1 = Time.now
    results = ev.evaluate heuristic, dataset
    t2 = Time.now
    puts "-" * 80, "Summary".center(80)
    puts "Fitness in training (mean): #{results[:training].reduce(&:+)/results[:training].length}"
    puts "Fitness in test (mean): #{results[:test].reduce(&:+)/results[:test].length}"
    puts "Reduction ratio: #{results[:reduction].reduce(&:+)/results[:reduction].length}"
    puts "Time spent: total #{results[:time].reduce(&:+)}, mean #{results[:time].reduce(&:+)/results[:time].length}"
  end
  #end

  # print a graph profile to text
  #printer = RubyProf::GraphPrinter.new(result)
  #printer.print(STDOUT, {})
end
