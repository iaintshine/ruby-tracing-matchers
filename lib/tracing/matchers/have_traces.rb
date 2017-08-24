module Tracing
  module Matchers
    # @private
    class HaveTraces
      def initialize(n)
      end

      def started
        self
      end

      def finished
        self
      end

      # @return [Boolean]
      def matches?(tracer)
      end

      # @return [String]
      def description
      end

      # @return [String]
      def failure_message
      end
      alias :failure_message_for_should :failure_message

      # @return [String]
      def failure_message_when_negated
      end
      alias :failure_message_for_should_not :failure_message_when_negated
    end
  end
end
