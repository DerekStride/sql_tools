module SqlTools
  class Constraint
    class << self
      def from(node)
        if node.children.any? { |child| child.type == :keyword_key }
          Index.new(node)
        else
          binding.b
        end
      end
    end
  end
end

