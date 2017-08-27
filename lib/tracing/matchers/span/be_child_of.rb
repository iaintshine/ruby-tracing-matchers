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
          @subject = span
          # TODO: add support for context
          @actual = parent_span(span)

          if any?
            !!@actual
          else
            expected_span_ids(span.tracer).any? { |span_id| @actual.context.span_id == span_id }
          end
        end

        # @return [String]
        def description
          any? ? "have a parent" : "have #{expected_message} parent"
        end

        # @return [String]
        def failure_message
          any? ? "expected a parent" : "expected #{expected_message} parent, got #{actual_message}"
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

        def parent_span(span)
          span.tracer
            .spans
            .find { |s| s.context.span_id == span.context.parent_span_id }
        end

        def expected_span_ids(tracer)
          case
          when @expected.respond_to?(:context) then [@expected.context.span_id]
          when @expected.respond_to?(:span_id) then [@expected.span_id]
          when @expected.is_a?(String) then expected_spans(tracer).map { |span| span.context.span_id }
          else nil
          end
        end

        def expected_spans(tracer)
          tracer.spans.select { |span| span.operation_name == @expected }
        end

        def expected_message
          case
          when @expected.respond_to?(:context) then "\"#{@expected.operation_name}\""
          when @expected.respond_to?(:span_id) then "span context with id \"#{@expected.span_id}\""
          when @expected.is_a?(String) then "\"#{@expected}\""
          else nil
          end
        end

        def actual_message
          case
          when @actual.respond_to?(:operation_name) then "\"#{@actual.operation_name}\""
          when @actual.nil? then "nothing"
          else @actual
          end
        end
      end
    end
  end
end
