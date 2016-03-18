require "bitarray"

# Additions to convert between arrays and bitarrays
class Array
  def to_bitarray len = max + 1
    BitArray.new(len).tap do |b|
      each { |i| b.set_bit i }
    end
  end
end

class BitArray
  def ones
    each_with_index.select{ |a, _| a.nonzero? }.map(&:last)
  end
end

module FeatureSelection
  class Heuristic
    def initialize dataset
      @rng = Random.new RANDOM_SEED
      @dataset = dataset
      @classifier = KNearest.new NUMBER_NEIGHBORS, @dataset
    end

    attr_reader :dataset, :classifier
  end
end
