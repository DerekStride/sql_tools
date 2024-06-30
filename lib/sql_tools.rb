# frozen_string_literal: true

require "tree_stand"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup

module SqlTools
  class Error < StandardError; end

  class << self
    def query_from_sql(sql) = query_from_tree(tree_from_sql(sql))
    def query_from_tree(tree) = SqlTools::QueryVisitor.new(tree.root_node).visit.query
    def tree_from_sql(sql) = parser.parse_string(sql)
    def parser = @parser ||= TreeStand::Parser.new("sql")
  end

  Table = Data.define(:name, :alias)
  Column = Data.define(:table, :name)
end
