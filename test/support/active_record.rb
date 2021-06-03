# frozen_string_literal: true

require "active_record"

ActiveRecord::Base.establish_connection "postgres:///ar_enum_test"
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = nil

# Apply a migration directly from your tests:
#
#   test "do something" do
#     schema do
#       drop_table :users if table_exists?(:users)
#
#       create_table :users do |t|
#         t.text :name, null: false
#       end
#     end
#   end
#
def schema(&block)
  ActiveRecord::Schema.define(version: 0, &block)
end
