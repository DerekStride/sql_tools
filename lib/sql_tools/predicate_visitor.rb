module SqlTools
  class PredicateVisitor < TreeStand::Visitor
    attr_reader :stack
    def initialize(node)
      super(node)
      @stack = []
    end

    def around_binary_expression(node)
      @stack << Predicate::Binary.new(nil, node.operator.text, nil)
      yield
      @stack[-3].right = @stack.pop
      @stack[-2].left = @stack.pop
    end

    def on_field(node)
      parent = node.parent
      # Case JOIN ON v.is_not_deleted
      @stack << node if parent.type == :join || parent.type == :where
      # Case JOIN ON _ AND v.is_not_deleted
      @stack << node if parent.type == :binary_expression
    end

    def on_literal(node) = on_field(node)
  end
end
