# frozen_string_literal: true

module AR
  module Enum
    module Adapter
      class EnumInDb
        def initialize(name:, labels:)
          @name = name
          @labels = labels
        end

        attr_reader :name, :labels
      end

      # @return [Array<EnumInDb>]
      def enum_types
        typnames = execute <<~SQL
          select
            t.typname,
            e.enumlabel
          from
            pg_type t,
            pg_enum e
          where
            t.oid = e.enumtypid
          order by
            e.enumsortorder
        SQL

        labels_by_types = typnames.each_with_object({}) do |elem, acc|
          acc[elem["typname"]] ||= []
          acc[elem["typname"]].push(elem["enumlabel"])
        end
        labels_by_types.map {|name, labels| EnumInDb.new(name: name, labels: labels) }
      end

      def create_enum(name, values)
        return if enum_exists?(name)

        values = values.map do |value|
          quote(value.to_s)
        end

        sql = <<-SQL
          CREATE TYPE #{name}
          AS ENUM (#{values.join(', ')})
        SQL

        execute(sql)
      end

      def enum_exists?(name)
        enum_types.map(&:name).include?(name.to_s)
      end

      def add_enum_label(name, value, options = {})
        sql = "ALTER TYPE #{name} ADD VALUE #{quote(value.to_s)}"

        if options[:before]
          sql = "#{sql} BEFORE #{quote(options[:before].to_s)}"
        elsif options[:after]
          sql = "#{sql} AFTER #{quote(options[:after].to_s)}"
        end

        execute(sql)
      end

      def rename_enum_label(name, from, to)
        sql = "ALTER TYPE #{name} RENAME VALUE #{quote(from.to_s)}" \
              " TO #{quote(to.to_s)}"
        execute(sql)
      end

      def drop_enum(name, options = {})
        sql = "DROP TYPE IF EXISTS #{name}"
        sql = "#{sql} CASCADE" if options[:cascade]

        execute(sql)
      end
    end
  end
end
