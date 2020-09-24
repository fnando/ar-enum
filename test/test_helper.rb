# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "bundler/setup"
require "ar/enum"
require "minitest/utils"
require "minitest/autorun"

ActiveRecord::Base.establish_connection "postgres:///test"
ActiveRecord::Migration.verbose = false

class Article < ActiveRecord::Base
end

module TestHelper
  def recreate_table
    ActiveRecord::Schema.define(version: 0) do
      drop_table(:articles) if data_source_exists?(:articles)
      execute "drop type if exists article_status cascade"
      execute "drop type if exists color cascade"
    end
  end

  def with_migration(&block)
    migration_class = if ActiveRecord::Migration.respond_to?(:[])
                        ActiveRecord::Migration[
                          ActiveRecord::Migration.current_version
                        ]
                      else
                        ActiveRecord::Migration
                      end

    Class.new(migration_class, &block).new
  end
end
