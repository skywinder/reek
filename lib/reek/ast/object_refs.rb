module Reek
  module AST
    #
    # Manages and counts the references out of a method to other objects.
    #
    # @api private
    class ObjectRefs  # :nodoc:
      def initialize
        @refs = Hash.new(0)
      end

      def record_reference_to(name)
        @refs[name] += 1
      end

      def references_to(name)
        @refs[name]
      end

      def max_keys
        max = @refs.values.max
        @refs.select { |_key, val| val == max }
      end

      def self_is_max?
        max_keys.length == 0 || @refs[:self] == @refs.values.max
      end
    end
  end
end
