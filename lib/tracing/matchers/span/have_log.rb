module Tracing
  module Matchers
    module Span
      # @private
      class HaveLog
        def initialize(**fields)
          @expected = fields
        end

        # @return [Boolean]
        def matches?(span)
          @subject = span
          @actual = span.logs.map { |log| log.fields.dup.tap { |h| h[:event] = log.event } }

          if any?
            @actual.any?
          else
            @actual.any? do |log|
              @expected.all? { |k, v| log.key?(k) && v == log[k] }
            end
          end
        end

        # @return [String]
        def description
          desc = "have log entry"
          desc << " #{@expected}" unless any?
          desc
        end

        # @return [String]
        def failure_message
          any? ? "expected any log entry" : "expected #{@expected} log entry, got #{@actual}"
        end
        alias :failure_message_for_should :failure_message

        # @return [String]
        def failure_message_when_negated
          any? ? "did not expect any log entry" : "did not expect #{@expected} log entry, got #{@actual}"
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
