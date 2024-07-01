module SqlTools
  class QueryVisitor < TreeStand::Visitor
    attr_reader :query

    def initialize(node)
      super(node)
      @ctes = {}
      @query = Query.new
    end

    def on_cte(node)
      cte = CommonTableExpression.new(node)
      @query.common_table_expressions[cte.name] = cte
    end

    def on_select(node)
      @query.select = node
    end

    def on_from(node)
      @query.from = node
    end

    def on_join(node)
      @query.join_nodes << node
    end
  end
end
