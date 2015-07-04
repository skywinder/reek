module Reek
  module AST  # :nodoc:
    ObjectRef = Struct.new(:name)
    #
    # Manages and counts the references out of a method to other objects.
    #
    # @api private
    class ObjectRefs  # :nodoc:
      def initialize
        @refs = Hash.new { |refs, name| refs[name] = [] }
      end

      def biggest_counts
        max = @refs.values.map(&:size).max
        Hash[@refs.select { |_name, refs| refs.size == max }.map do |name, refs|
          [name, refs.size]
        end]
      end

      def record_reference_to(name)
        @refs[name] << ObjectRef.new(name)
      end

      def references_to(name)
        @refs[name]
      end

      def self_is_max?
        @refs.empty? || biggest_counts.keys.include?(:self)
      end
    end
  end
end
