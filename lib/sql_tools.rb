# frozen_string_literal: true

require "tree_stand"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup

module SqlTools
  class Error < StandardError; end

  Table = Data.define(:name, :alias)
  Column = Data.define(:table, :name)
  ColumnSelection = Data.define(:name, :table, :column_name)
  InvocationSelection = Data.define(:name, :invocation)
  AllFieldsSelection = Data.define
end
