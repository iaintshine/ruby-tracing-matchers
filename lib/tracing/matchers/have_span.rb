module Tracing
  module Matchers
    # @private
    class HaveSpan
      def initialize(operation_name)
        @expected = operation_name
        @predicates = []
      end

      def in_progress
        @state_predicate = RSpec::Matchers::BuiltIn::BePredicate.new(:be_started)
        self
      end
      alias :started :in_progress

      def finished
        @state_predicate = RSpec::Matchers::BuiltIn::BePredicate.new(:be_finished)
        self
      end

      def with_tag(*args)
        @predicates << Tracing::Matchers::Span::HaveTag.new(*args)
        self
      end
      alias :with_tags :with_tag

      def with_log(**fields)
        @predicates << Tracing::Matchers::Span::HaveLog.new(**fields)
        self
      end
      alias :with_logs :with_log

      def with_baggage(*args)
        @predicates << Tracing::Matchers::Span::HaveBaggage.new(*args)
        self
      end

      def child_of(parent = :any)
        @predicates << Tracing::Matchers::Span::BeChildOf.new(parent)
        self
      end
      alias :with_parent :child_of

      # @return [Boolean]
      def matches?(tracer)
        @subject = tracer
        @actual = actual_spans

        @actual.any? { |span| all_predicates.all? { |matcher| matcher.matches?(span) } }
      end

      # @return [String]
      def description
        "have a#{expected_span_description}"
      end

      # @return [String]
      def failure_message
        "expected a#{expected_span_description}"
      end
      alias :failure_message_for_should :failure_message

      # @return [String]
      def failure_message_when_negated
        "did not expect#{expected_span_description}"
      end
      alias :failure_message_for_should_not :failure_message_when_negated

      private

      def expected_span_description
        desc = ""
        desc << " #{@state_predicate.description.gsub('be ', '')}" if state_predicate?
        desc << " span"
        desc << " with operation name \"#{@expected}\"" if operation_name?
        @predicates.each { |matcher| desc << " #{matcher.description.gsub('have', 'with')}" }
        desc
      end

      def actual_spans
        @subject.spans.select(&expected_predicate)
      end

      def expected_predicate
        operation_name? ? -> (span) { span.operation_name == @expected } : -> (_) { true }
      end

      def operation_name?
        @expected.is_a?(String)
      end

      def state_predicate?
        @state_predicate
      end

      def all_predicates
        @all_predicates = (@predicates + [@state_predicate]).compact
      end
    end
  end
end
