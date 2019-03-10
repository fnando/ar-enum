# frozen_string_literal: true

require "active_support/all"
require "active_record"
require "active_record/connection_adapters/postgresql_adapter"
require "active_record/schema_dumper"
require "active_record/migration/command_recorder"
require "ar/enum/version"

module AR
  module Enum
    require "ar/enum/adapter"
    require "ar/enum/schema_dumper"
    require "ar/enum/command_recorder"
  end
end

ActiveRecord::Migration::CommandRecorder.include AR::Enum::CommandRecorder
ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.include AR::Enum::Adapter
ActiveRecord::SchemaDumper.prepend AR::Enum::SchemaDumper
