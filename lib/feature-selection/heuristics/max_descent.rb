require_relative "local_search"

module FeatureSelection
  class MaximumDescent < LocalSearch
    def select_next
      neighbor, fitness = neighborhood.to_a.max_by &:last
      [neighbor, fitness] if fitness > @fitness # returns nil otherwise
    end
  end
end
