module Tracing
  module Matchers
    module Span
      # @private
      class HaveTag
        def initialize(*args)
          @expected = args.last.is_a?(Hash) ? args.delete_at(-1) : Hash.new
          args.each_slice(2) { |k, v| @expected[k] = v }
        end

        # @return [Boolean]
        def matches?(span)
          @subject = span
          @actual = span.tags

          if any?
            @actual.any?
          else
            @expected.all? { |k, v| @actual.key?(k) && values_match?(v, @actual[k]) }
          end
        end

        # @return [String]
        def description
          desc = "have tags"
          desc << " #{@expected}" unless any?
          desc
        end

        # @return [String]
        def failure_message
          any? ? "expected any tag" : "expected #{@expected} tags, got #{@actual}"
        end
        alias :failure_message_for_should :failure_message

        # @return [String]
        def failure_message_when_negated
          any? ? "did not expect any tag" : "did not expect #{@expected} tags, got #{@actual}"
        end
        alias :failure_message_for_should_not :failure_message_when_negated

        private

        def any?
          @expected.empty?
        end

        def values_match?(expected, actual)
          expected.is_a?(Regexp) ? expected.match(actual) : expected == actual
        end
      end
    end
  end
end
