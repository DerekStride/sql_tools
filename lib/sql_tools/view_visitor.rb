module SqlTools
  class ViewVisitor < TreeStand::Visitor
    attr_reader :view

    def initialize(node)
      super(node)
      @ctes = {}
      @view = View.new
    end

    def on_cte(node)
      cte = CommonTableExpression.new(node)
      @view.common_table_expressions[cte.name] = cte
    end

    def on_select(node)
      @view.select = node
    end

    def on_from(node)
      @view.from = node
    end
  end
end
