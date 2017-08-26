module Tracing
  module Matchers
    # @private
    class HaveTraces
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
          @actual = traces.size
          @actual == @expected
        else
          traces.any?
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
          message = "expected #{@expected} traces"
          message << " #{@state}" if @state
          message << ", got #{@actual}"
          message
        else
          "expected any trace #{@state}".strip
        end
      end
      alias :failure_message_for_should :failure_message

      # @return [String]
      def failure_message_when_negated
        if exactly?
          message = "did not expect #{@expected} traces"
          message << " #{@state}" if @state
          message << ", got #{@actual}"
          message
        else
          "did not expect traces #{@state}".strip
        end
      end
      alias :failure_message_for_should_not :failure_message_when_negated

      private

      def state
        @state || :started
      end

      def exactly?
        @expected.is_a?(Fixnum)
      end

      def traces
        @subject.spans
          .group_by { |span| span.context.trace_id }
          .map { |trace_id, spans| Trace.new(trace_id, spans) }
          .select { |trace| @state == :finished ? trace.finished? : true }
      end

      class Trace < Struct.new(:trace_id, :spans)
        def finished?
          spans.all? { |span| !span.in_progress? }
        end
      end
    end
  end
end
