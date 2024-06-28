# frozen_string_literal: true

require "test_helper"

module SqlTools
  class QueryVisitorTest < Minitest::Test
    def test_visit_select
      query = query_from_sql(<<~SQL)
        SELECT * FROM table
      SQL

      assert_instance_of(Query, query)

      assert_equal(1, query.selections.size)
      assert_equal(AllFieldsSelection.new, query.selections.first)

      assert_equal(1, query.objects.size)
      assert_equal(Table.new(name: "table", alias: "table"), query.objects.first)
    end

    def test_visit_select_with_predicate
      query = query_from_sql(<<~SQL)
        SELECT *
        FROM table
        WHERE id = 1
      SQL

      assert_equal(1, query.predicates.size)
      assert_equal(
        Predicate::Binary.new(
          left: Column.new(table: nil, name: "id"),
          operator: "=",
          right: "1",
        ),
        query.predicates.first,
      )
    end
  end
end
