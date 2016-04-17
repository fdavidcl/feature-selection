require "bitarray"
require "knn_cv"

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
      @classifier = KnnCv::Classifier.new CONFIG.knn[:num_neighbors], @dataset, Random.new(@rng.seed)
      @evaluations = 0
    end

    attr_reader :dataset, :classifier

    private
    def fitness_for solution
      @evaluations += 1
      @classifier.fitness_for solution
    end

    def random_solution
      size = @dataset.input_count
      BitArray.new(size).tap do |solution|
        # Method 1: Randomly set each bit to 0 or 1
        (0..size - 1).each do |i|
          solution.set_bit(i) if @rng.rand(2) == 1
        end

        # Method 2: Set a random sample of bits
        # (0 ... size).to_a.sample(@rng.rand(size), random: @rng).each{ |i| solution.set_bit i }
      end
    end
  end
end
