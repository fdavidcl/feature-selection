require "bitarray"

# Additions to convert between arrays and bitarrays
class Array
  def to_bitarray len
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
    def initialize dataset, debug: false, random: Random.new(CONFIG.random_seed)
      @debug = debug
      @rng = random
      @dataset = dataset
      @dataset.instances.each{|ins| ins.each{ |dat| puts "WARNING" if dat == Float::NAN}}
      #puts @dataset.instances.to_s
      @classifier = CKNearest.new CONFIG.knn[:num_neighbors], @dataset, Random.new(@rng.seed)
      @evaluations = 0
    end

    attr_reader :dataset, :classifier

    def fitness_for solution
      @evaluations += 1
      @classifier.fitness_for solution
    end
  end
end
