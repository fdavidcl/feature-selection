
require "feature-selection/config"

module FeatureSelection
  CONFIG = if File.exists?(Config::DEFAULT_FILENAME)
      Config.new
    else
      puts "Generating new configuration file in #{Config::DEFAULT_FILENAME}"
      Config.generate
    end

  RNG = Random.new(CONFIG.random_seed)
end

require "feature-selection/version"
require "feature-selection/classifiers"
require "feature-selection/heuristics"
require "feature-selection/evaluator"
