# frozen_string_literal: true

require "fileutils"

namespace :treesitter do
  task :install do
    app_root = File.expand_path("..", __dir__)
    tmp_dir = File.join(app_root, "tmp")

    repo_url = "https://github.com/derekstride/tree-sitter-sql.git"
    repo_sha = "cdb7cde9bf70b194ab8beb5069fbbc3c9640284e"
    repo_dir = "tree-sitter-sql-#{repo_sha}"

    parser_so = File.join(tmp_dir, repo_dir, "parser.so")
    target_sql = File.join(app_root, "treesitter", "sql.so")

    next if [parser_so, target_sql].all? { |f| File.exist?(f) }

    FileUtils.chdir(app_root) do
      FileUtils.mkdir_p "tmp"
      FileUtils.mkdir_p "treesitter"
    end

    FileUtils.chdir(tmp_dir) do
      system! "git clone --depth=1 #{repo_url} #{repo_dir}" unless File.exist?(repo_dir)

      FileUtils.chdir(repo_dir) do
        system! "git fetch origin #{repo_sha}"
        system! "git checkout #{repo_sha}"

        compile_parser(parser_so, target_sql)
      end
    end
  end
end

def compile_parser(shared_object, target)
  return if File.exist?(shared_object) && File.exist?(target)

  puts "Compiling..."
  system! "cc -shared -fPIC -I./src src/parser.c src/scanner.c -o parser.so"

  puts "Copying parser.so to ./treesitter/#{File.basename(target)}"
  FileUtils.cp(shared_object, target)
end

def system!(*args)
  system(*args) || abort("\n== Command #{args} failed ==")
end
