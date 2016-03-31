require "yaml"
require "yaml/store"

module FeatureSelection
  class Config
    DEFAULT_FILENAME = "config.yml"

    def self.generate file = DEFAULT_FILENAME
      store = YAML::Store.new file
      store.transaction do
        {
          random_seed: 1,
          debug: false,
          knn: {
            num_neighbors: 3
          },
          cross_validation: 5,
          max_evaluations: 15000,
          simulated_annealing: {
            max_neighbors_factor: 10,
            max_selections_factor: 0.1,
            worsening: 0.3,
            prob_accept: 0.3,
            final_temp: 1e-3
          },
          tabu_search: {
            num_neighbors: 30,
            initial_size_factor: 1.0/3
          }
        }.each do |key, value|
          store[key] = value
        end
      end

      Config.new file
    end

    def initialize file = DEFAULT_FILENAME
      @config = YAML.load(File.read(file))

      # Define reader methods for each key in the configuration
      @config.each do |key, value|
        define_singleton_method "#{key}" do
          value
        end
      end
    end
  end
end