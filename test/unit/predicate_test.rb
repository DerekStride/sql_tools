# frozen_string_literal: true

require "test_helper"

module SqlTools
  class PredicateTest < Minitest::Test
    def test_simple_predicate
      query = query_from_sql(<<~SQL)
        SELECT *
        FROM table
        WHERE id = 1
      SQL

      assert_equal(
        Predicate::Binary.new(
          left: Column.new(table: Table.new("table", "table"), name: "id"),
          operator: "=",
          right: "1",
        ),
        query.predicate,
      )
    end

    def test_multiple_predicates
      query = query_from_sql(<<~SQL)
        SELECT *
        FROM table
        WHERE id = 1
          AND name = "derek"
      SQL

      assert_equal(
        Predicate::Binary.new(
          left: Predicate::Binary.new(
            left: Column.new(table: Table.new("table", "table"), name: "id"),
            operator: "=",
            right: "1",
          ),
          operator: "AND",
          right: Predicate::Binary.new(
            left: Column.new(table: Table.new("table", "table"), name: "name"),
            operator: "=",
            right: "\"derek\"",
          ),
        ),
        query.predicate,
      )
    end

    def test_many_predicates_with_precedence
      query = query_from_sql(<<~SQL)
        SELECT *
        FROM table
        WHERE id = 1
          AND name = "derek"
          AND phone = "555-0000"
          OR id >= 2
          AND name = "stride"
      SQL

      assert_equal(
        Predicate::Binary.new(
          left: Predicate::Binary.new(
            left: Predicate::Binary.new(
              left: Predicate::Binary.new(
                left: Column.new(table: Table.new("table", "table"), name: "id"),
                operator: "=",
                right: "1",
              ),
              operator: "AND",
              right: Predicate::Binary.new(
                left: Column.new(table: Table.new("table", "table"), name: "name"),
                operator: "=",
                right: "\"derek\"",
              ),
            ),
            operator: "AND",
            right: Predicate::Binary.new(
              left: Column.new(table: Table.new("table", "table"), name: "phone"),
              operator: "=",
              right: "\"555-0000\"",
            ),
          ),
          operator: "OR",
          right: Predicate::Binary.new(
            left: Predicate::Binary.new(
              left: Column.new(table: Table.new("table", "table"), name: "id"),
              operator: ">=",
              right: "2",
            ),
            operator: "AND",
            right: Predicate::Binary.new(
              left: Column.new(table: Table.new("table", "table"), name: "name"),
              operator: "=",
              right: "\"stride\"",
            ),
          ),
        ),
        query.predicate,
      )
    end

    def test_multiple_predicates_with_precedence
      query = query_from_sql(<<~SQL)
        SELECT *
        FROM table
        WHERE id = 1
          AND name = "derek"
          OR id >= 2
          AND name = "stride"
      SQL

      assert_equal(
        Predicate::Binary.new(
          left: Predicate::Binary.new(
            left: Predicate::Binary.new(
              left: Column.new(table: Table.new("table", "table"), name: "id"),
              operator: "=",
              right: "1",
            ),
            operator: "AND",
            right: Predicate::Binary.new(
              left: Column.new(table: Table.new("table", "table"), name: "name"),
              operator: "=",
              right: "\"derek\"",
            ),
          ),
          operator: "OR",
          right: Predicate::Binary.new(
            left: Predicate::Binary.new(
              left: Column.new(table: Table.new("table", "table"), name: "id"),
              operator: ">=",
              right: "2",
            ),
            operator: "AND",
            right: Predicate::Binary.new(
              left: Column.new(table: Table.new("table", "table"), name: "name"),
              operator: "=",
              right: "\"stride\"",
            ),
          ),
        ),
        query.predicate,
      )
    end
  end
end

