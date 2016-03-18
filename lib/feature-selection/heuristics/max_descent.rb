require_relative "monotonic_search"

module FeatureSelection
  class MaximumDescent < MonotonicSearch
    private
    def select_next
      neighbor, fitness = neighborhood.max_by &:last
      [neighbor, fitness] if fitness > @fitness # returns nil otherwise
    end
  end
end
