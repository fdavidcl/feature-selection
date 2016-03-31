require 'rserve/simpler'

module FeatureSelection
  class Dataset
    # Class method: Reads an ARFF file and returns a Dataset out of it
    def self.read_arff filename, class_col = nil
      r = Rserve::Simpler.new cmd_init: CONFIG.rserve_cmd
      begin
        data = r >> %Q{
          library(foreign)
          read.arff("#{File.absolute_path(__dir__)}/#{filename}")
        }

        # Converts output to a Dataframe object
        dataframe = data.names.zip(data).to_h.to_dataframe
      rescue Rserve::Connection::EvalError
        # Assume the problem was caused by the user
        raise ArgumentError, "We couldn't read the file #{filename}"
      end

      self.new dataframe, class_col, File.basename(filename, ".*")
    end

    def self.data name, class_col = nil
      r = Rserve::Simpler.new cmd_init: CONFIG.rserve_cmd
      begin
        data = r >> %Q{
          data(#{name})
          #{name}
        }

        # Converts output to a Dataframe object
        dataframe = data.names.zip(data).to_h.to_dataframe
      rescue Rserve::Connection::EvalError
        # Assume the problem was caused by the user
        raise ArgumentError, "We couldn't get the dataset #{filename}"
      end

      self.new dataframe, class_col, name
    end

    attr_reader :dataframe, :class_col, :name

    def initialize dataframe = {}.to_dataframe, class_col = nil, name = ""
      # Dataframes are stored as a hash of columns, like so:
      #   dataframe.data =
      #     {
      #       "attribute1" => [ value_1, value_2, ... ]
      #       "attribute2" => [ value_1, value_2, ... ]
      #       "class"      => [ 0, 1, ... ]
      #     }
      @dataframe = dataframe
      # Assume class is last column by default
      @class_col = class_col || dataframe.data.length - 1
      @class_name = @dataframe.data.keys[@class_col]
      @name = name.empty? ? "(no name)" : name
    end

    def input_count
      # Count all input features
      @dataframe.data.length - 1
    end

    def inputs
      (0 ... @dataframe.data.length).to_a.tap{ |a| a.delete class_col }
    end

    def num_instances
      # Length of the first column
      @dataframe.data.first.last.length
    end

    def instances
      # Get instances by transposing data matrix
      @dataframe.data.to_a.map(&:last).transpose
    end

    def take amount
      names = @dataframe.data.keys
      Dataset.new(names.zip(instances.take(amount).transpose).to_h.to_dataframe, class_col, "#{@name}_take#{amount}")
    end
    def drop amount
      names = @dataframe.data.keys
      Dataset.new(names.zip(instances.drop(amount).transpose).to_h.to_dataframe, class_col, "#{@name}_take#{amount}")
    end

    # Stratified partitioning
    def partition num_partitions, random: Random.new(CONFIG.random_seed)
      # Save names for later
      names = @dataframe.data.keys
      # Group instances by class
      strata = instances.group_by{ |i| i[class_col] }

      strata.each_value.map do |str|
        # Randomly distribute instances from each stratum onto partitions
        str.shuffle(random: random).each_slice((str.length - 1)/num_partitions + 1).to_a
      end.transpose.map.each_with_index do |p, i|
        # Get all instances together and convert to columns
        cols = p.flatten(1).transpose
        # Convert to dataframe, generate new dataset for each partition
        Dataset.new(names.zip(cols).to_h.to_dataframe, class_col, "#{@name}_p#{i}")
      end
    end

    def to_s
      "Dataset #{@name} (#{num_instances} instances, #{input_count} input features, class column: #{class_col})"
    end

    def display
      to_s
    end
  end
end
