# SqlTools

SqlTools is a collection of tools for working with SQL ASTs. It's the intersection of
[ruby_tree_sitter](https://github.com/faveod/ruby-tree-sitter/) &
[tree-sitter-sql](https://github.com/derekstride/tree-sitter-sql), letting you parse SQL queries and transform them into
semantic Ruby objects.

## Installation

If you're having trouble installing `ruby_tree_sitter` try installing the libraries for the latest supported version of
libtree-sitter.

```bash
git clone https://github.com/tree-sitter/tree-sitter
cd tree-sitter
git checkout tags/v0.22.6
make
sudo make install
```

To install the SQL parser run the rake task.

```bash
bundle exec rake treesitter:install
```

## Usage

```ruby
SqlTools.query_from_sql(<<~SQL)
  SELECT id, name
  FROM table_a
  WHERE id > 10
    AND id < 20
SQL
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DerekStride/sql_tools. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/DerekStride/sql_tools/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SqlTools project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/DerekStride/sql_tools/blob/main/CODE_OF_CONDUCT.md).
