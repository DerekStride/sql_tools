module SqlTools
  class Predicate
    Binary = Struct.new(:left, :operator, :right) do
      def to_s = "(#{left} #{operator} #{right})"
      def inspect = to_s
    end

    class Builder
      def initialize(query)
        @query = query
      end

      def build(predicate)
        case predicate
        when Predicate::Binary
          predicate.left = build(predicate.left)
          predicate.right = build(predicate.right)
          predicate
        when TreeStand::Node
          type_from_node(predicate)
        else
          raise "Unknown predicate: #{predicate}"
        end
      end

      private

      def type_from_node(node)
        case node.type
        when :field
          table = if table_alias = node.find_node("(field (object_reference name: (identifier) @table_alias))")&.text
            @query.object_alias_map.fetch(table_alias)
          elsif @query.objects.size == 1
            @query.objects.first
          end
          Column.new(table, node.name.text)
        when :literal
          node.text
        else
          raise "Unknown node type: #{node.type}"
        end
      end
    end
  end
end
