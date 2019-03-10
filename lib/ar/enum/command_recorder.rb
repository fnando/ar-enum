# frozen_string_literal: true

module AR
  module Enum
    module CommandRecorder
      def create_enum(name, values)
        record(__method__, [name, values])
      end

      def rename_enum_label(name, from, to)
        record(__method__, [name, from, to])
      end

      def invert_create_enum(args)
        name, _ = args
        [:drop_enum, name]
      end

      def invert_rename_enum_label(args)
        name, to, from = args
        [:rename_enum_label, [name, from, to]]
      end
    end
  end
end
