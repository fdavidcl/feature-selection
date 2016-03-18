require_relative "monotonic_search"

module FeatureSelection
  class FirstDescent < MonotonicSearch
    private
    def select_next
      neighborhood.detect do |attempt, fitness|
        fitness > @fitness
      end
    end
  end
end
