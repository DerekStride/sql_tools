module SqlTools
  class Predicate
    Binary = Struct.new(:left, :operator, :right)

    class Builder
      def initialize(view)
        @view = view
      end

      def build(node)
        case node.type
        when :binary_expression
          Binary.new(
            type_from_node(node.left),
            node.operator.text,
            type_from_node(node.right),
          )
        when :field
          type_from_node(node)
        else
          raise "Unknown node type: #{node.type}"
        end
      end

      private

      def type_from_node(node)
        case node.type
        when :field
          if table_alias = node.find_node("(field (object_reference name: (identifier) @table_alias))")&.text
            table = @view.object_alias_map.fetch(table_alias)
          end
          # table ||= @view.driving_table
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
