require "feature-selection/arff"

module FeatureSelection
  class Dataset
    # Class method: Reads an ARFF file and returns a Dataset out of it
    def self.read_arff filename, class_col = nil
      arfffile = ARFF::ARFFFile.load(filename)

      self.new arfffile, class_col, File.basename(filename, ".*")
    end

    attr_reader :class_col, :name, :classes

    def initialize arfffile = ARFF::ARFFFile.new, class_col = nil, name = ""
      @arfffile = arfffile
      # Assume class is last column by default
      @class_col = class_col || input_count
      @classes = calculate_classes
      #@class_name = @dataframe.data.keys[@class_col]
      @name = name.empty? ? @arfffile.relation : name
    end

    def instances
      @arfffile.data
    end

    def input_count
      # Count all input features
      instances[0].length - 1
    end

    def inputs
      (0 ... input_count).to_a.tap{ |a| a.delete class_col }
    end

    def num_instances
      # Length of the first column
      instances.length
    end

    # Stratified partitioning
    def partition num_partitions, random: Random.new(CONFIG.random_seed)
      # Group instances by class
      strata = instances.group_by{ |i| i[class_col] }

      strata.each_value.map do |str|
        # Randomly distribute instances from each stratum onto partitions
        #puts str.shuffle(random: random).each_slice((str.length - 1)/num_partitions + 1).to_a
        str.shuffle(random: random).each_slice((str.length - 1)/num_partitions + 1).to_a
      end
        .transpose
        .map
        .each_with_index do |p, i|
        # Get all instances together and build an ARFF data object
        arffdata = ARFF::ARFFFile.new(
          relation: "#{@arfffile.relation}_part#{i}",
          comment: @arfffile.comment,
          attribute_names: @arfffile.attribute_names,
          attribute_types: @arfffile.attribute_types,
          attribute_data: @arfffile.attribute_data,
          data: p.flatten(1)
        )
        Dataset.new(arffdata, class_col, "#{@name}_p#{i}")
      end
    end

    def normalize!
      columns = instances.transpose

      columns.map do |column|
        
      end
    end

    def to_s
      "Dataset #{@name} (#{num_instances} instances, #{input_count} input features, class column: #{class_col})"
    end

    def display
      to_s
    end

    def inspect
      to_s
    end

    private

    def calculate_classes
      cl = instances.map{ |instance| instance[class_col] }

      # Select all unique classes and assign them a number
      corresponding = cl.uniq.each_with_index.to_h
      # Return the array of corresponding numbers
      cl.map { |c| corresponding[c] }
    end
  end
end
