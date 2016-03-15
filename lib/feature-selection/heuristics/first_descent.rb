require_relative "local_search"

module FeatureSelection
  class FirstDescent < LocalSearch
    def select_next
      neighborhood.detect do |(attempt, fitness)|
        fitness > @fitness
      end
    end
  end
end
