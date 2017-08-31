module Tracing
  module Matchers
    module Span
      # @private
      class FollowAfter
        include Test::TypeCheck

        def initialize(previous)
          NotNull! previous
          @expected = previous
        end

        # @return [Boolean]
        def matches?(span)
          @tracer = span.tracer
          @subject = span

          return false unless expected_index && subject_index
          expected_index < subject_index
        end

        # @return [String]
        def description
          "follow after #{expected_message}"
        end

        # @return [String]
        def failure_message
          "expected #{subject_message} to follow after #{expected_message}"
        end
        alias :failure_message_for_should :failure_message

        # @return [String]
        def failure_message_when_negated
          "did not expected #{subject_message} to follow after #{expected_message}"
        end
        alias :failure_message_for_should_not :failure_message_when_negated

        private

        def expected_index
          @tracer.spans.find_index(expected_span)
        end

        def subject_index
          @tracer.spans.find_index(@subject)
        end

        def expected_span
          case
          when @expected.respond_to?(:context) then @expected
          when @expected.is_a?(String)
            @tracer.spans.find { |span| span.operation_name == @expected }
          else @expected
          end
        end

        def expected_message
          case
          when @expected.respond_to?(:context) then "the span with operation name \"#{@expected.operation_name}\""
          when @expected.is_a?(String) then "a span with operation name \"#{@expected}\""
          else nil
          end
        end

        def subject_message
          "a span with operation name \"#{@subject.operation_name}\""
        end
      end
    end
  end
end
