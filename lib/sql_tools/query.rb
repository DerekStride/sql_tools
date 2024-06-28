module SqlTools
  class Query
    attr_accessor :select, :from
    attr_reader :common_table_expressions

    def initialize
      @common_table_expressions = {}
    end

    def selections
      terms = select.query(<<~QUERY)
        (select_expression
          (term
            value: [
              (field
                (object_reference name: (identifier) @table_alias)
                name: (identifier) @column_name)
              (invocation) @invocation
              (all_fields) @all_fields
            ]
            alias: (identifier)? @selection_name))
      QUERY
      terms.map! do |captures|
        selection_name = captures["selection_name"]&.text || captures["column_name"]&.text

        if table_alias = captures["table_alias"]
          table = object_alias_map[table_alias.text]
          column_name = captures["column_name"].text
          ColumnSelection.new(selection_name, table, column_name)
        elsif invocation = captures["invocation"]
          InvocationSelection.new(selection_name, invocation)
        elsif captures["all_fields"]
          AllFieldsSelection.new
        else
          raise "Unknown selection type"
        end
      end
    end

    def relations
      objects.each_with_object({}) do |object, map|
        map[object] ||= []
        map[object] << predicates.select do |p|
          (p.left.is_a?(Column) && p.left.table == object) ||
            (p.right.is_a?(Column) && p.right.table == object)
        end
      end
    end

    def predicates
      @predicates ||= begin
        nodes = from.query(<<~QUERY).map { |captures| captures["predicate"] }
          (from
            (join
              predicate: (_) @predicate))
            (where
              predicate: (_) @predicate)
        QUERY

        predicate_builder = Predicate::Builder.new(self)
        predicates = nodes.flat_map do |predicate|
          PredicateVisitor.new(predicate).visit.clauses
            .map { |p| predicate_builder.build(p) }
        end.to_set
      end
    end

    def objects = object_alias_map.values.to_set

    def object_alias_map
      @table_alias_map ||= @from.query("(relation) @relation").each_with_object({}) do |captures, map|
        relation = captures["relation"]
        relation_name = relation.children.first.name.text
        relation_alias = relation.respond_to?(:alias) ? relation.alias.text : relation_name

        map[relation_alias] = common_table_expressions[relation_name] || Table.new(relation_name, relation_alias)
        map[relation_name] = map[relation_alias]
      end
    end
  end
end
