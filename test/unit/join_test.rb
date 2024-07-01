# frozen_string_literal: true

require "test_helper"

module SqlTools
  class JoinTest < Minitest::Test
    def test_join_predicates
      query = query_from_sql(<<~SQL)
        SELECT *
        FROM table_a a
        JOIN table_b b
          ON a.id = b.a_id
      SQL

      expected = Predicate::Binary.new(
        left: Column.new(table: Table.new("table_a", "a"), name: "id"),
        operator: "=",
        right: Column.new(table: Table.new("table_b", "b"), name: "a_id"),
      )

      assert_equal(1, query.joins.size)
      assert_equal(expected, query.predicate)
      assert_equal(expected, query.joins.first.predicate)
    end

    def test_join_predicates_in_the_where
      skip("bug in the parser on empty join")
      query = query_from_sql(<<~SQL)
        SELECT *
        FROM table_a a
        JOIN table_b b
        WHERE a.id = b.a_id
      SQL

      expected = Predicate::Binary.new(
        left: Column.new(table: Table.new("table_a", "a"), name: "id"),
        operator: "=",
        right: Column.new(table: Table.new("table_b", "b"), name: "a_id"),
      )

      assert_equal(1, query.joins.size)
      assert_equal(expected, query.predicate)
      assert_equal(expected, query.joins.first.predicate)
    end

    def test_join_predicate_spread_out
      query = query_from_sql(<<~SQL)
        SELECT *
        FROM table_a a
        JOIN table_b b
          ON a.id = b.a_id
        WHERE a.shard_id = b.shard_id
      SQL

      expected = Predicate::Binary.new(
        left: Predicate::Binary.new(
          left: Column.new(table: Table.new("table_a", "a"), name: "id"),
          operator: "=",
          right: Column.new(table: Table.new("table_b", "b"), name: "a_id"),
        ),
        operator: "AND",
        right: Predicate::Binary.new(
          left: Column.new(table: Table.new("table_a", "a"), name: "shard_id"),
          operator: "=",
          right: Column.new(table: Table.new("table_b", "b"), name: "shard_id"),
        ),
      )

      assert_equal(1, query.joins.size)
      assert_equal(expected, query.predicate)
      assert_equal(expected, query.joins.first.predicate)
    end

    def test_many_join_predicates_spread_out
      skip("predicate precedence is messed up here")
      query = query_from_sql(<<~SQL)
        SELECT *
        FROM table_a a
        JOIN table_b b
          ON a.id = b.a_id
            AND a.shard_id = b.shard_id
        WHERE a.user_id = b.user_id
          AND a.id = 4
      SQL

      assert_equal(
        Predicate::Binary.new(
          left: Predicate::Binary.new(
            left: Predicate::Binary.new(
              left: Predicate::Binary.new(
                left: Column.new(table: Table.new("table_a", "a"), name: "id"),
                operator: "=",
                right: Column.new(table: Table.new("table_b", "b"), name: "a_id"),
              ),
              operator: "AND",
              right: Predicate::Binary.new(
                left: Column.new(table: Table.new("table_a", "a"), name: "shard_id"),
                operator: "=",
                right: Column.new(table: Table.new("table_b", "b"), name: "shard_id"),
              ),
            ),
            operator: "AND",
            right: Predicate::Binary.new(
              left: Column.new(table: Table.new("table_a", "a"), name: "user_id"),
              operator: "=",
              right: Column.new(table: Table.new("table_b", "b"), name: "user_id"),
            ),
          ),
          operator: "AND",
          right: Predicate::Binary.new(
            left: Column.new(table: Table.new("table_a", "a"), name: "id"),
            operator: "=",
            right: "4",
          ),
        ),
        query.predicate,
      )

      assert_equal(1, query.joins.size)
      assert_equal(
        Predicate::Binary.new(
          left: Predicate::Binary.new(
            left: Predicate::Binary.new(
              left: Column.new(table: Table.new("table_a", "a"), name: "id"),
              operator: "=",
              right: Column.new(table: Table.new("table_b", "b"), name: "a_id"),
            ),
            operator: "AND",
            right: Predicate::Binary.new(
              left: Column.new(table: Table.new("table_a", "a"), name: "shard_id"),
              operator: "=",
              right: Column.new(table: Table.new("table_b", "b"), name: "shard_id"),
            ),
          ),
          operator: "AND",
          right: Predicate::Binary.new(
            left: Column.new(table: Table.new("table_a", "a"), name: "user_id"),
            operator: "=",
            right: Column.new(table: Table.new("table_b", "b"), name: "user_id"),
          ),
        ),
        query.joins.first.predicate,
      )
    end
  end
end


