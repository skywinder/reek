require_relative 'smell_configuration'
require_relative 'smell_detector'
require_relative 'smell_warning'

module Reek
  module Smells
    #
    # A class that publishes a getter or setter for an instance variable
    # invites client classes to become too intimate with its inner workings,
    # and in particular with its representation of state.
    #
    # This detector raises a warning for every public
    # +attr_writer+, +attr_accessor+, and +attr+ with the writable set to true.
    #
    # See {file:docs/Attribute.md} for details.
    # @api private
    #
    # TODO: Catch attributes declared "by hand"
    class Attribute < SmellDetector
      ATTR_DEFN_METHODS = [:attr_writer, :attr_accessor]

      def initialize(*args)
        super
      end

      def self.contexts # :nodoc:
        [:sym]
      end

      #
      # Checks whether the given class declares any attributes.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        attributes_in(ctx).map do |attribute, line|
          SmellWarning.new self,
                           context: ctx.full_name,
                           lines: [line],
                           message:  'is a writeable attribute',
                           parameters: { name: attribute.to_s }
        end
      end

      private

      def attributes_in(module_ctx)
        if module_ctx.visibility == :public
          call_node = module_ctx.exp
          [[call_node.name, call_node.line]]
        else
          []
        end
      end
    end
  end
end
