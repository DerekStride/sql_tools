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

