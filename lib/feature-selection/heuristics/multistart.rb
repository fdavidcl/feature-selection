module FeatureSelection
  class BasicMultistart < FirstDescent
    def outer_loop
      CONFIG.multistart[:initial].times do
        # Set current solution as a new random solution
        @solution = random_solution
        # Reset evaluation count
        @evaluations = 0
        # Run local search here
        basic_local_search
      end
    end
  end
end
