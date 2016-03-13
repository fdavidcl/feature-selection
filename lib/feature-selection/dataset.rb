require 'rserve/simpler'

module FeatureSelection
  class Dataset
    # Class method: Reads an ARFF file and returns a Dataset out of it
    def self.read_arff filename
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

      self.new dataframe, File.basename(filename, ".*")
    end

    def self.data name
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

      self.new dataframe, name
    end

    attr_accessor :dataframe

    def initialize dataframe = {}.to_dataframe, name = ""
      @dataframe = dataframe
      @name = name.empty? ? "(no name)" : name
    end

    # def features
    #   @dataframe.data.keys
    # end

    def num_features
      # Count all input features
      @dataframe.data.length - 1
    end

    def num_instances
      # Length of the first column
      @dataframe.data.first.last.length
    end

    def to_s
      "Dataset #{@name} (#{num_instances} instances, #{num_features} features)"
    end

    def inspect
      to_s
    end
  end
end
