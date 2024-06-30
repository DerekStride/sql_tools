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
      assert_equal(Selection::AllFields.new(Table.new("table", "table")), query.selections.first)

      assert_equal(1, query.objects.size)
      assert_equal(Table.new(name: "table", alias: "table"), query.objects.first)
    end
  end
end
