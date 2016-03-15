#!/usr/bin/env ruby
require 'ruby-prof'
require "bundler/setup"
require "feature-selection"

arr = FeatureSelection::Dataset.read_arff("../../arrhythmia.arff")
mlibras = FeatureSelection::Dataset.read_arff("../../movement_libras.arff")
wdbc = FeatureSelection::Dataset.read_arff("../../wdbc.arff", 0)
iris = FeatureSelection::Dataset.data("iris")

iris.tap do |dataset|
  puts "Using #{dataset}"

  heuristics = {
    "Sequential Forward Selection" => FeatureSelection::SequentialSelection.new(dataset),
    "Sequential Backward Selection" => FeatureSelection::SequentialSelection.new(dataset, false),
    "First-descent Local Search" => FeatureSelection::FirstDescent.new(dataset)
  }

  # profile the code
  #result = RubyProf.profile do
  heuristics.each do |name, heuristic|
    puts "\n#{"-" * 80}\n|#{name.center(78)}|\n#{"-" * 80}"
    puts "Solution found: #{heuristic.run.join " with fitness "}"
  end
  #end
end

# print a graph profile to text
# printer = RubyProf::GraphPrinter.new(result)
# printer.print(STDOUT, {})
