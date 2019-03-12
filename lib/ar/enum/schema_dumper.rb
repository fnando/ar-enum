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

        stream.puts("  # These are enum types available on this database") if list.any?

        list.each do |row|
          labels = row["labels"].split(",")
          name = row["name"].to_sym

          statement = [
            "  create_enum",
            "#{name.inspect},",
            labels.inspect
          ].join(" ")

          stream.puts(statement)
        end

        stream.puts
      end
    end
  end
end
