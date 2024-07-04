module SqlTools
  class ColumnDefinition
    def initialize(node)
      @node = node
    end

    def name = @node.name.text
  end
end
