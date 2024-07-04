module SqlTools
  class Index
    def initialize(node)
      @node = node
    end

    def columns
      @node.query(<<~QUERY).map do |match|
        (ordered_columns (column name: (identifier) @column_name))
      QUERY
        match["column_name"].text
      end
    end

    def primary_key?
      @node.any? { |child| child.type == :keyword_primary } &&
        @node.any? { |child| child.type == :keyword_key }
    end

    def name
      return :primary_key if primary_key?

      @node.name.text.delete("`")
    end
  end
end


