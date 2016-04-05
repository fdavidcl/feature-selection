require "feature-selection/arff"

module FeatureSelection
  class Dataset
    # Class method: Reads an ARFF file and returns a Dataset out of it
    def self.read_arff filename, class_col = nil
      arfffile = ARFF::ARFFFile.load(filename)

      # Assume last column is class by defualt
      class_col = arfffile.data[0].length - 1 if class_col.nil?

      self.new(
        self.calculate_inputs(arfffile, class_col),
        self.calculate_classes(arfffile, class_col),
        self.which_numeric(arfffile, class_col),
        File.basename(filename, ".*")
      )
    end

    attr_reader :name, :classes, :instances, :class_count, :numeric_attrs

    def initialize instances, classes, numeric_attrs, name = ""
      @instances = instances
      @classes = classes
      @numeric_attrs = numeric_attrs
      @class_count = @classes.uniq.length
      @name = name.empty? ? "(no name)" : name
    end

    def input_count
      # Count all input features
      instances[0].length
    end

    def num_instances
      # Length of the first column
      instances.length
    end

    # Stratified partitioning
    def partition num_partitions, random: Random.new(CONFIG.random_seed)
      # Group instances by class
      strata = (0 ... @instances.length).group_by { |index| @classes[index] }

      strata.each_value.map do |str|
        # Randomly distribute instances from each stratum onto partitions
        str.shuffle(random: random).each_slice((str.length - 1)/num_partitions + 1).to_a
      end
        .transpose
        .map
        .each_with_index do |p, i|
        # Get all instances together and build a new Dataset
        p.flatten!
        Dataset.new(
          @instances.values_at(*p),
          @classes.values_at(*p),
          @numeric_attrs,
          "#{@name}_p#{i}"
        )
      end
    end

    def normalize!
      columns = instances.clone.transpose

      (0 ... input_count).each do |index|
        if @numeric_attrs[index] == 1 && columns[index][0].is_a?(Numeric)
          max = columns[index].max
          min = columns[index].min
          # Prevent NaN generation
          columns[index].map!{ |e| (e - min)/(max - min) } if max - min > 0
        else # Nominal or string
          corresponding = columns[index].uniq.each_with_index.to_h
          columns[index].map!{ |e| corresponding[e] }
        end
      end

      @instances = columns.transpose
      self
    end

    def to_s
      "Dataset #{@name} (#{num_instances} instances, #{input_count} input features, unique classes: #{@class_count})"
    end

    def display
      to_s
    end

    def inspect
      to_s
    end
    private

    def self.calculate_classes arfffile, class_col
      cl = arfffile.data.map{ |instance| instance[class_col] }

      # Select all unique classes and assign them a number
      corresponding = cl.uniq.each_with_index.to_h
      # Return the array of corresponding numbers
      cl.map { |c| corresponding[c] }
    end

    def self.calculate_inputs arfffile, class_col
      columns = arfffile.data.clone.transpose

      # Remove class column
      columns.slice! class_col, 1
      columns.transpose
    end

    def self.which_numeric arfffile, class_col
      types = arfffile.attribute_types
      names = arfffile.attribute_names.clone
      names.slice! class_col, 1

      names.map do |at|
        if types[at] == :numeric
          1
        else
          0
        end
      end
    end
  end
end
