require_relative "generational"
require_relative "local_search"

module FeatureSelection
  class Memetic < GenerationalGenetic
    include LocalTools

  end
end
