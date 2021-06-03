# frozen_string_literal: true

module AR
  module Enum
    module SchemaDumper
      def header(stream)
        super
        enum_section(stream)
      end

      def enum_section(stream)
        list = @connection.enum_types

        stream.puts("  # These are enum types available on this database") if list.any?

        list.each do |enum_in_db|
          statement = [
            "  create_enum",
            "#{enum_in_db.name.to_sym.inspect},",
            enum_in_db.labels.inspect
          ].join(" ")

          stream.puts(statement)
        end

        stream.puts
      end
    end
  end
end
