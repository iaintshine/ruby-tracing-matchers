module Tracing
  module Matchers
    # @private
    class HaveSpan
      def initialize(operation_name)
      end

      def in_progress
        self
      end
      alias :started :in_progress

      def finished
        self
      end

      def with_tags(**tags)
        self
      end

      def with_logs
        self
      end

      def with_log(**fields)
        self
      end

      def with_baggage(**baggage)
        self
      end

      def child_of(parent)
        self
      end
      alias :with_parent :child_of

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
