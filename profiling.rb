#!/usr/bin/env ruby
require 'ruby-prof'
require "bundler/setup"
require "feature-selection"

emotions = FeatureSelection::Dataset.read_arff("../../emotions.arff")
iris = FeatureSelection::Dataset.data("iris")
sfs = FeatureSelection::SeqForwardSelection.new emotions
ls = FeatureSelection::LocalSearch.new emotions

# profile the code
result = RubyProf.profile do
  sfs.run
end

# print a graph profile to text
printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, {})
