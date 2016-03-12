
module FeatureSelection
  NUMBER_NEIGHBORS = 3

  class Heuristic
    def initialize dataset
      @dataset = dataset
      @classifier = KNearest.new NUMBER_NEIGHBORS, @dataset
    end

    attr_reader :dataset
  end
end
