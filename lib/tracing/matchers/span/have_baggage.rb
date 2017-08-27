module Tracing
  module Matchers
    module Span
      # @private
      class HaveBaggage
        def initialize(*args)
          @expected = args.last.is_a?(Hash) ? args.delete_at(-1) : Hash.new
          args.each_slice(2) { |k, v| @expected[k] = v }
        end

        # @return [Boolean]
        def matches?(span)
          @subject = span
          @actual = span.context.baggage

          if any?
            @actual.any?
          else
            @expected.all? { |k, v| @actual.key?(k) && v == @actual[k] }
          end
        end

        # @return [String]
        def description
          desc = "have baggage"
          desc << " #{@expected}" unless any?
          desc
        end

        # @return [String]
        def failure_message
          any? ? "expected any baggage" : "expected #{@expected} baggage, got #{@actual}"
        end
        alias :failure_message_for_should :failure_message

        # @return [String]
        def failure_message_when_negated
          any? ? "did not expect any baggage" : "did not expect #{@expected} baggage, got #{@actual}"
        end
        alias :failure_message_for_should_not :failure_message_when_negated

        private

        def any?
          @expected.empty?
        end
      end
    end
  end
end
