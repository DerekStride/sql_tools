module SqlTools
  class SchemaVisitor < TreeStand::Visitor
    attr_reader :schema

    def initialize(node)
      super(node)
      @schema = Schema.new
    end

    def on_create_table(node)
      @schema.create_table = node
    end

    def on_column_definition(node)
      @schema.columns << ColumnDefinition.new(node)
    end

    def on_constraint(node)
      @schema.constraints << Constraint.from(node)
    end
  end
end
