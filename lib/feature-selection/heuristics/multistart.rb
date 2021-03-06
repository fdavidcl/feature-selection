require_relative "local_search"

module FeatureSelection
  class BasicMultistart < FirstDescent
    private
    def outer_loop
      CONFIG.multistart[:initial].times do
        # Set current solution as a new random solution
        initial = random_solution
        self.solution = [initial, fitness_for(initial)]
        # Run local search here
        basic_local_search
      end
    end
  end
end
