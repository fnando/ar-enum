# frozen_string_literal: true

module AR
  module Enum
    module SchemaDumper
      def header(stream)
        super
        enum_types(stream)
      end

      def enum_types(stream)
        list = @connection.enum_types.to_a

        stream.puts("  # These are enum types created on this database") if list.any?

        list.each do |row|
          labels = row["labels"].split(",")
          name = row["name"]

          statement = [
            "  create_enum",
            "#{name.to_sym.inspect},",
            labels.inspect
          ].join(" ")

          stream.puts(statement)
        end

        stream.puts
      end
    end
  end
end
