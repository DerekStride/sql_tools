# frozen_string_literal: true

require "bundler/setup"

require "minitest/reporters"
require "minitest/focus"
require "minitest/autorun"
require "debug"

require "sql_tools"

Minitest::Reporters.use!

TreeStand.configure do
  config.parser_path = File.join(__dir__, "..", "treesitter")
end

module TreeStandHelper
  def query_from_sql(source) = visit_tree(parse(source))
  def visit_tree(tree) = SqlTools::QueryVisitor.new(tree.root_node).visit.query
  def parse(source) = parser.parse_string(source)
  def parser = @parser ||= TreeStand::Parser.new("sql")
end

module Minitest
  class Test
    include TreeStandHelper
  end
end
