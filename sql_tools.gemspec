# frozen_string_literal: true

require_relative "lib/sql_tools/version"

Gem::Specification.new do |spec|
  spec.name = "sql_tools"
  spec.version = SqlTools::VERSION
  spec.authors = ["derekstride"]
  spec.email = ["derek@stride.host"]

  spec.summary = "Collection of tools for working with SQL ASTs."
  spec.homepage = "https://github.com/derekstride/sql_tools"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ruby_tree_sitter", "~> 1.0"
  spec.add_dependency "zeitwerk"
end
