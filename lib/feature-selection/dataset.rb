require 'rserve/simpler'

module FeatureSelection
  class Dataset
    # Class method: Reads an ARFF file and returns a Dataset out of it
    def self.read_arff filename, class_col = nil
      r = Rserve::Simpler.new
      begin
        data = r >> %Q{
          if (!("foreign" %in% installed.packages()[, "Package"]))
            install.packages("foreign")
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
      r = Rserve::Simpler.new
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

    attr_reader :dataframe, :class_col

    def initialize dataframe = {}.to_dataframe, class_col = nil, name = ""
      @dataframe = dataframe
      # Assume class is last column by default
      @class_col = class_col || dataframe.data.length - 1
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

    def to_s
      "Dataset #{@name} (#{num_instances} instances, #{input_count} input features, class column: #{class_col})"
    end

    def inspect
      to_s
    end
  end
end
