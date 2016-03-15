#!/usr/bin/env ruby
require 'ruby-prof'
require "bundler/setup"
require "feature-selection"

arr = FeatureSelection::Dataset.read_arff("../../arrhythmia.arff")
mlibras = FeatureSelection::Dataset.read_arff("../../movement_libras.arff")
wdbc = FeatureSelection::Dataset.read_arff("../../wdbc.arff", 0)
iris = FeatureSelection::Dataset.data("iris")

mlibras.tap do |dataset|
  puts "Using #{dataset}"

  sfs = FeatureSelection::SeqForwardSelection.new dataset
  ls = FeatureSelection::LocalSearch.new dataset

  # profile the code
  #result = RubyProf.profile do
    puts sfs.run
  #end
end

# print a graph profile to text
# printer = RubyProf::GraphPrinter.new(result)
# printer.print(STDOUT, {})
