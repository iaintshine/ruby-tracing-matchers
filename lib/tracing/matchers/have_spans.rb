module Tracing
  module Matchers
    # @private
    class HaveSpans
      def initialize(n)
        @expected = n
      end

      def started
        @state = :started
        self
      end

      def finished
        @state = :finished
        self
      end

      # @return [Boolean]
      def matches?(tracer)
        @subject = tracer

        if exactly?
          @actual = spans.size
          @actual == @expected
        else
          spans.any?
        end
      end

      # @return [String]
      def description
        desc = "have "
        desc << "exactly #{@expected} " if exactly?
        desc << "traces #{@state}"
        desc.strip
      end

      # @return [String]
      def failure_message
        if exactly?
          message = "expected #{@expected} spans"
          message << " #{@state}" if @state
          message << ", got #{@actual}"
          message
        else
          "expected any span #{@state}".strip
        end
      end
      alias :failure_message_for_should :failure_message

      # @return [String]
      def failure_message_when_negated
        if exactly?
          message = "did not expect #{@expected} spans"
          message << " #{@state}" if @state
          message << ", got #{@actual}"
          message
        else
          "did not expect spans #{@state}".strip
        end
      end
      alias :failure_message_for_should_not :failure_message_when_negated

      private

      def state
        @state || :started
      end

      def spans
        state == :finished ? @subject.finished_spans : @subject.spans
      end

      def exactly?
        @expected.is_a?(Fixnum)
      end
    end
  end
end
