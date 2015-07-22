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
      VISIBILITY_MODIFIERS = [:private, :public, :protected]

      def initialize(*args)
        super
      end

      def self.contexts # :nodoc:
        [:class, :module]
      end

      #
      # Checks whether the given class declares any attributes.
      #
      # @return [Array<SmellWarning>]
      #
      def examine_context(ctx)
        @visiblity_tracker = {}
        @visiblity_mode = :public
        attributes_in(ctx).map do |attribute, line|
          SmellWarning.new self,
                           context: ctx.full_name,
                           lines: [line],
                           message:  "declares the writeable attribute #{attribute}",
                           parameters: { name: attribute.to_s }
        end
      end

      private

      def attributes_in(module_ctx)
        result = Set.new
        module_ctx.local_nodes(:send) do |call_node|
          result += track_attributes(call_node)
        end
        result.select { |args| recorded_public_methods.include?(args[0]) }
      end

      def track_attributes(call_node)
        if attribute_writer? call_node
          return track_arguments call_node.args, call_node.line
        end
        track_visibility call_node if visibility_modifier? call_node
        []
      end

      def attribute_writer?(call_node)
        method_name = call_node.method_name
        ATTR_DEFN_METHODS.include?(method_name) ||
          method_name == :attr && call_node.args.last.type == :true
      end

      def track_arguments(args, line)
        args.select { |arg| arg.type == :sym }.map { |arg| track_argument(arg, line) }
      end

      def track_argument(arg, line)
        arg_name = arg.children.first
        @visiblity_tracker[arg_name] = @visiblity_mode
        [arg_name, line]
      end

      def visibility_modifier?(call_node)
        VISIBILITY_MODIFIERS.include?(call_node.method_name)
      end

      def track_visibility(call_node)
        if call_node.arg_names.any?
          call_node.arg_names.each { |arg| @visiblity_tracker[arg] = call_node.method_name }
        else
          @visiblity_mode = call_node.method_name
        end
      end

      def recorded_public_methods
        @visiblity_tracker.select { |_, visbility| visbility == :public }
      end
    end
  end
end
