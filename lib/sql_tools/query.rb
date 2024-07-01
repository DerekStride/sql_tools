module SqlTools
  class Query
    attr_accessor :select, :from, :join_nodes
    attr_reader :common_table_expressions

    def initialize
      @common_table_expressions = {}
      @join_nodes = []
    end

    def selections
      terms = select.query(<<~QUERY)
        (select_expression
          (term
            value: [
              (field
                (object_reference name: (identifier) @table_alias)?
                name: (identifier) @column_name)
              (invocation) @invocation
              (all_fields
                (object_reference name: (identifier) @table_alias)?) @all_fields
            ]
            alias: (identifier)? @selection_name))
      QUERY
      terms.map! do |captures|
        selection_name = captures["selection_name"]&.text || captures["column_name"]&.text

        if captures["all_fields"]
          table = if table_alias = captures["table_alias"]
            object_alias_map[table_alias.text]
          elsif objects.size == 1
            objects.first
          end
          Selection::AllFields.new(table)
        elsif table_alias = captures["table_alias"]
          table = object_alias_map[table_alias.text]
          column_name = captures["column_name"].text
          Selection::Column.new(selection_name, Column.new(table, column_name))
        elsif (column_name = captures["column_name"]&.text) && objects.size == 1
          table = objects.first
          Selection::Column.new(selection_name, Column.new(table, column_name))
        elsif invocation = captures["invocation"]
          Selection::Invocation.new(selection_name, invocation)
        else
          raise "Unknown selection type"
        end
      end
    end

    def joins
      join_nodes.map do |join_node|
        object_name = join_node.find_node(<<~QUERY).text
          (join
            (relation
             (object_reference name: (identifier) @object_name)))
        QUERY

        filter = PredicateFilter.new(self)
        object = object_alias_map[object_name]
        predicate = filter.filter(object)

        if join_node.children.any? { |child| child.type == :keyword_left }
          LeftJoin.new(object, predicate)
        else
          InnerJoin.new(object, predicate)
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

    def predicate
      @predicate ||= begin
        nodes = from.query(<<~QUERY).map { |captures| captures["predicate"] }
          (from
            (join
              predicate: (_) @predicate))
            (where
              predicate: (_) @predicate)
        QUERY

        builder = Predicate::Builder.new(self)
        predicates = nodes.flat_map do |predicate|
          visitor = PredicateVisitor.new(predicate).visit
          binding.b unless visitor.stack.size == 1
          builder.build(visitor.stack.last)
        end

        right = predicates.pop

        # This needs to pluck the left & right from binary expressions & rebuild the tree.
        # TODO: maybe this is the rotate algorithm, TBD
        while left = predicates.pop
          predicate = Predicate::Binary.new(left, "AND", right)
          right = predicate
        end

        right
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
