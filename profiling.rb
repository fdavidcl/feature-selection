#!/usr/bin/env ruby
require 'ruby-prof'
require "bundler/setup"
require "feature-selection"

arr = FeatureSelection::Dataset.read_arff("../../arrhythmia.arff")
mlibras = FeatureSelection::Dataset.read_arff("../../movement_libras.arff")
wdbc = FeatureSelection::Dataset.read_arff("../../wdbc.arff", 0)
iris = FeatureSelection::Dataset.data("iris")

arr.tap do |dataset|
  puts "Using #{dataset}. Let's partition:"

  partitions = (1..5).map{ dataset.partition 2 }

  # Falta correr el kNN directamente sobre el dataset

  heuristics = {
    "No selection (kNN with all features)" => FeatureSelection::NoSelection.new(dataset),
    #{}"Sequential Forward Selection" => FeatureSelection::SequentialSelection.new(dataset),
    #{}"Sequential Backward Selection" => FeatureSelection::SequentialSelection.new(dataset, false),
    "First-descent Local Search" => FeatureSelection::FirstDescent.new(dataset),
    "Maximum-descent Local Search" => FeatureSelection::MaximumDescent.new(dataset)
    #{}"Simulated Annealing" => FeatureSelection::SimAnnealing.new(dataset)
  }

  # profile the code
  #result = RubyProf.profile do
  heuristics.each do |name, heuristic|
    puts "\n#{"-" * 80}\n|#{name.center(78)}|\n#{"-" * 80}"
    puts "Solution found: #{heuristic.run.join " with fitness "}"
  end
  #end

  # print a graph profile to text
  # printer = RubyProf::GraphPrinter.new(result)
  # printer.print(STDOUT, {})
end
