# frozen_string_literal: true

require "active_support/all"
require "active_record"
require "active_record/connection_adapters/postgresql_adapter"
require "active_record/connection_adapters/postgresql/schema_statements"
require "active_record/connection_adapters/postgresql/schema_definitions"
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

ActiveSupport.on_load(:active_record) do
  require "active_record/connection_adapters/postgresql_adapter"
  silence_warnings do
    ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES = ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES.dup
  end

  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.include(
    Module.new do
      def create_table_definition(*args, **kwargs)
        ActiveRecord::Base.connection.enum_types.each do |enum|
          ActiveRecord::ConnectionAdapters::PostgreSQL::ColumnMethods.class_eval do
            ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES[enum["name"].to_sym] = {name: enum["name"]}

            define_method(enum["name"]) do |*names, **options|
              names.each do |name|
                column(name, enum["name"].to_sym, **options)
              end
            end
          end
        end

        super
      end
    end
  )

  ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaStatements.class_eval do
    original_fetch_type_metadata = instance_method(:fetch_type_metadata)

    define_method(:fetch_type_metadata) do |*args|
      type_metadata = original_fetch_type_metadata.bind_call(self, *args)

      if type_metadata.type == :enum
        type_metadata = ActiveRecord::ConnectionAdapters::SqlTypeMetadata.new(
          sql_type: type_metadata.sql_type,
          type: type_metadata.sql_type.to_sym,
          limit: type_metadata.limit,
          precision: type_metadata.precision,
          scale: type_metadata.scale
        )
        type_metadata = ActiveRecord::ConnectionAdapters::PostgreSQLTypeMetadata.new(type_metadata)

        ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES[type_metadata.type] = {name: "character varying"}
      end

      type_metadata
    end
  end

  ActiveRecord::Migration::CommandRecorder.include AR::Enum::CommandRecorder
  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.include AR::Enum::Adapter
  ActiveRecord::SchemaDumper.prepend AR::Enum::SchemaDumper
end
