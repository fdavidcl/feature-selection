require_relative "first_descent"

module FeatureSelection
  class BasicMultistart < FirstDescent
    private
    def outer_loop
      CONFIG.multistart[:initial].times do
        # Set current solution as a new random solution
        initial = random_solution
        self.solution = [initial, fitness_for(initial)]
        # Reset evaluation count
        @evaluations = 0
        # Run local search here
        basic_local_search
      end
    end
  end
end
