# frozen_string_literal: true

require "test_helper"

module SqlTools
  class SchemaTest < Minitest::Test
    def test_create_table_returns_a_schema
      schema = schema_from_sql(<<~SQL)
        CREATE TABLE table (
          id INT NOT NULL,
          shard_id BIGINT NOT NULL,
          name VARCHAR(255) NOT NULL,
          PRIMARY KEY (shard_id, id),
          KEY `idx_name` (name),
          KEY `idx_shard_name` (shard_id, name)
        );
      SQL

      assert_equal(3, schema.columns.size)
      assert_equal(["id", "shard_id", "name"], schema.columns.map(&:name))
      assert_equal([:primary_key, "idx_name", "idx_shard_name"], schema.indices.map(&:name))
      assert_equal(
        [
          ["shard_id", "id"],
          ["name"],
          ["shard_id", "name"],
        ],
        schema.indices.map(&:columns),
      )
    end
  end
end
