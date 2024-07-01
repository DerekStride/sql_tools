module SqlTools
  class PredicateFilter
    def initialize(query)
      @query = query
    end

    def filter(object)
      @stack = []
      filter_recursive(object, @query.predicate)

      right = @stack.pop

      while left = @stack.pop
        predicate = Predicate::Binary.new(left, "AND", right)
        right = predicate
      end

      right
    end

    private

    def filter_recursive(object, predicate)
      case predicate
      when Predicate::Binary
        @stack << predicate if filter_recursive(object, predicate.left) || filter_recursive(object, predicate.right)
        false
      when SqlTools::Column
        predicate.table == object
      else
        raise "Unknown predicate type: #{predicate}"
      end
    end
  end
end
