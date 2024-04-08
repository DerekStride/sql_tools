# frozen_string_literal: true

require "test_helper"

module SqlTools
  class ViewVisitorTest < Minitest::Test
    def setup
      @parser = TreeStand::Parser.new("sql")
    end

    def test_visit_select
      tree = @parser.parse_string(<<~SQL)
        SELECT * FROM table
      SQL

      visitor = ViewVisitor.new(tree.root_node).visit
      view = visitor.view

      assert_instance_of(View, view)

      assert_equal(1, view.selections.size)
      assert_equal(AllFieldsSelection.new, view.selections.first)

      assert_equal(1, view.objects.size)
      assert_equal(Table.new(name: "table", alias: "table"), view.objects.first)
    end

    def test_visit_select_with_predicate
      tree = @parser.parse_string(<<~SQL)
        SELECT *
        FROM table
        WHERE id = 1
      SQL

      visitor = ViewVisitor.new(tree.root_node).visit
      view = visitor.view


      assert_equal(1, view.predicates.size)
      assert_equal(
        Predicate::Binary.new(
          left: Column.new(table: nil, name: "id"),
          operator: "=",
          right: "1",
        ),
        view.predicates.first,
      )
    end
  end
end
