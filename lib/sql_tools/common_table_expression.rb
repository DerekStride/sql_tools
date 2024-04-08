module SqlTools
  class CommonTableExpression
    attr_reader :node

    def initialize(node)
      @node = node
    end

    def name = node.children.first.text.delete('`')

    def view
      @view ||= ViewVisitor.new(node.children[-2]).visit.view
    end

    def inspect = "#<class CommonTableExpression name=#{name.inspect}>"
  end
end
