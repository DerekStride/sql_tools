module SqlTools
  class PredicateVisitor < TreeStand::Visitor
    attr_reader :clauses

    def initialize(node)
      super(node)
      @clauses = []
    end

    def on_binary_expression(node)
      return if node.operator.type == :keyword_and
      return unless [:field, :literal].intersect?([node.left.type, node.right.type])

      clauses << node
    end

    def on_field(node)
      parent = node.parent
      # Case JOIN ON v.is_not_deleted
      clauses << node if parent.type == :join || parent.type == :where
      # Case JOIN ON _ AND v.is_not_deleted
      clauses << node if parent.type == :binary_expression && parent.operator.type == :keyword_and
    end
  end
end
