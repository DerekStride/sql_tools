module SqlTools
  class Schema
    attr_accessor :create_table
    attr_reader :columns, :constraints

    def initialize
      @columns = []
      @constraints = []
    end

    def indices = @constraints.select { |c| c.is_a?(Index) }
  end
end
