# frozen_string_literal: true

require "fileutils"

namespace :treesitter do
  task :install do
    app_root = File.expand_path("..", __dir__)
    exe = File.join(app_root, "exe", "install_tree_sitter_sql")
    system(exe) || abort("\n== Command #{exe} failed ==")
  end
end
