require_relative "local_search"

module FeatureSelection
  class MaximumDescent < LocalSearch
    private
    def select_next
      neighbor, fitness = neighborhood.lazy.take(@max_evaluations - @evaluations).max_by &:last
      [neighbor, fitness] if !neighbor.nil? && fitness > @fitness # returns nil otherwise
    end
  end
end
