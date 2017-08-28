module Tracing
  module Matchers
    module Span
      # @private
      class BeChildOf
        def initialize(parent)
          @expected = parent
        end

        # @return [Boolean]
        def matches?(span)
          @tracer = span.tracer
          @subject = span
          # actual is either Span, or SpanContext
          @actual = parent_of(@subject)

          case
          when any? then !!@actual
          when @actual.nil? && @expected then false
          else
            expected_span_id == actual_span_id
          end
        end

        # @return [String]
        def description
          any? ? "have a parent" : "have #{expected_message} as the parent"
        end

        # @return [String]
        def failure_message
          any? ? "expected a parent" : "expected #{expected_message} as the parent, got #{actual_message}"
        end
        alias :failure_message_for_should :failure_message

        # @return [String]
        def failure_message_when_negated
          any? ? "did not expect the parent" : "did not expect #{expected_message} parent, got #{actual_message}"
        end
        alias :failure_message_for_should_not :failure_message_when_negated

        private

        def any?
          @expected == :any
        end

        def parent_of(subject)
          return nil unless subject.context.parent_span_id

          parent_span = @tracer
                          .spans
                          .find { |span| span.context.span_id == subject.context.parent_span_id }

          parent_span || subject.context
        end

        def actual_span_id
          case
          when @actual.respond_to?(:context) then @actual.context.span_id
          when @actual.respond_to?(:parent_span_id) then @actual.parent_span_id
          else @actual
          end
        end

        def expected_span_id
          case
          when @expected.respond_to?(:context) then @expected.context.span_id
          when @expected.respond_to?(:span_id) then @expected.span_id
          when @expected.is_a?(String) then @tracer.spans.find { |span| span.operation_name == @expected }&.context&.span_id
          else @expected
          end
        end

        def expected_spans(tracer)
          tracer.spans.select { |span| span.operation_name == @expected }
        end

        def expected_message
          case
          when @expected.respond_to?(:context) then "the span with operation name \"#{@expected.operation_name}\""
          when @expected.respond_to?(:span_id) then "the span context with id \"#{@expected.span_id}\""
          when @expected.is_a?(String) then "a span with operation name \"#{@expected}\""
          else nil
          end
        end

        def actual_message
          case
          when @actual.respond_to?(:operation_name) then "a span with operation name \"#{@actual.operation_name}\""
          when @actual.respond_to?(:parent_span_id) then "a span context with id \"#{@actual.parent_span_id}\""
          when @actual.nil? then "nothing"
          else @actual
          end
        end
      end
    end
  end
end
