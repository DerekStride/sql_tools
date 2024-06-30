# frozen_string_literal: true

require "test_helper"

module SqlTools
  class SelectionTest < Minitest::Test
    def test_select_table_star
      query = query_from_sql(<<~SQL)
        SELECT t.* FROM table t
      SQL

      assert_equal(1, query.selections.size)
      assert_equal(Selection::AllFields.new(Table.new("table", "t")), query.selections.first)
    end

    def test_select_star
      query = query_from_sql(<<~SQL)
        SELECT * FROM table
      SQL

      assert_equal(1, query.selections.size)
      assert_equal(Selection::AllFields.new(Table.new("table", "table")), query.selections.first)
    end

    def test_prefixed_columns
      query = query_from_sql(<<~SQL)
        SELECT table.id, table.name FROM table
      SQL

      expected = [
        Selection::Column.new("id", Column.new(Table.new("table", "table"), "id")),
        Selection::Column.new("name", Column.new(Table.new("table", "table"), "name")),
      ]
      assert_equal(expected, query.selections)
    end

    def test_basic_columns
      query = query_from_sql(<<~SQL)
        SELECT id, name FROM table
      SQL

      expected = [
        Selection::Column.new("id", Column.new(Table.new("table", "table"), "id")),
        Selection::Column.new("name", Column.new(Table.new("table", "table"), "name")),
      ]
      assert_equal(expected, query.selections)
    end

    def test_columns_with_aliased_table
      query = query_from_sql(<<~SQL)
        SELECT t.id, t.name FROM table t
      SQL

      expected = [
        Selection::Column.new("id", Column.new(Table.new("table", "t"), "id")),
        Selection::Column.new("name", Column.new(Table.new("table", "t"), "name")),
      ]
      assert_equal(expected, query.selections)
    end

    def test_columns_with_alias
      query = query_from_sql(<<~SQL)
        SELECT t.id, t.name AS table_name FROM table t
      SQL

      expected = [
        Selection::Column.new("id", Column.new(Table.new("table", "t"), "id")),
        Selection::Column.new("table_name", Column.new(Table.new("table", "t"), "name")),
      ]
      assert_equal(expected, query.selections)
    end

    def test_star_from_join
      query = query_from_sql(<<~SQL)
        SELECT a.*
        FROM table_a a
        JOIN table_b b
          ON a.id = b.a_id
      SQL

      expected = [
        Selection::AllFields.new(Table.new("table_a", "a")),
      ]
      assert_equal(expected, query.selections)

      query = query_from_sql(<<~SQL)
        SELECT a.*, table_b.*
        FROM table_a a
        JOIN table_b
          ON a.id = table_b.a_id
      SQL

      expected = [
        Selection::AllFields.new(Table.new("table_a", "a")),
        Selection::AllFields.new(Table.new("table_b", "table_b")),
      ]
      assert_equal(expected, query.selections)

      query = query_from_sql(<<~SQL)
        SELECT *
        FROM table_a a
        JOIN table_b
          ON a.id = table_b.a_id
      SQL

      expected = [
        Selection::AllFields.new(nil),
      ]
      assert_equal(expected, query.selections)
    end

    def test_columns_from_join
      query = query_from_sql(<<~SQL)
        SELECT a.id AS a_id, b.name b_name
        FROM table_a a
        JOIN table_b b
          ON a.id = b.a_id
      SQL

      expected = [
        Selection::Column.new("a_id", Column.new(Table.new("table_a", "a"), "id")),
        Selection::Column.new("b_name", Column.new(Table.new("table_b", "b"), "name")),
      ]
      assert_equal(expected, query.selections)
    end
  end
end

