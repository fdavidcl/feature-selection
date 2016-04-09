require_relative "local_search"

module FeatureSelection
  class FirstDescent < LocalSearch
    private
    def select_next
      neighborhood.lazy.take(@max_evaluations - @evaluations).detect do |attempt, fitness|
        fitness > @fitness
      end
    end
  end
end
