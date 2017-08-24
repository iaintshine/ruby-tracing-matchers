require "tracing/matchers/version"
require "tracing/matchers/have_traces"
require "tracing/matchers/have_span"

module Tracing
  module Matchers
    # The `have_traces` matcher tests that the tracer traced any or a specific
    # number of spans.
    #
    # @example
    #
    #   # Passes if either `tracer.spans`, or `tracer.finished_spans` includes any span
    #   expect(tracer).to have_traces
    #
    #   # Passes if either `tracer.spans`, or `tracer.finished_spans` includes exactly 10 spans
    #   expect(tracer).to have_traces(10)
    #
    #   # Passes if `tracer.spans` includes any span
    #   expect(tracer).to have_traces.started
    #
    #   # Passes if `tracer.finished_spans` includes any span
    #   expect(tracer).to have_traces.finished
    #
    # @note It's possible to chain `started` and `finished` at the same time.
    #  Expect that only the last method will be applied e.g. `have_traces.finished.started`
    #  will result in application of `started`.
    #
    # @param [Fixnum] n expected number of traced spans
    # @return [HaveTraces]
    #
    # @see HaveTraces#started
    # @see HaveTraces#finished
    def have_traces(n = anything)
      Tracing::Matchers::HaveTraces.new(n)
    end

    # The `have_span` matcher tests that the tracer traced a span matching a criteria.
    #
    # @example
    #
    #   # Behaves very similar to have_traces without any arguments.
    #   expect(tracer).to have_span
    #
    #   # Passes if the tracer traced span with the operation name "User Load".
    #   expect(tracer).to have_span("User Load")
    #
    #   # Passes if the tracer traced span with the operation name "User Load"
    #   # which is still in progress.
    #   expect(tracer).to have_span("User Load").in_progress
    #
    #   # Same as above
    #   expect(tracer).to have_span("User Load").started
    #
    #   # Passes if the tracer traced span with the operation name "User Load"
    #   # which has finished.
    #   expect(tracer).to have_span("User Load").finished
    #
    #   # Passes if the tracer traced any span which has any tag
    #   expect(tracer).to have_span.with_tags
    #
    #   # Passes if the tracer traced span with the operation name "User Load"
    #   # and which has any tag
    #   expect(tracer).to have_span("User Load").with_tags
    #
    #   # Passes if the tracer traced span with the operation name "User Load"
    #   # and which has a tag 'component' => 'ActiveRecord'.
    #   expect(tracer).to have_span("User Load").with_tags('component' => 'ActiveRecord')
    #
    #   # Passes if the tracer traced any span which has any log entry
    #   expect(tracer).to have_span.with_logs
    #
    #   # Passes if the tracer traced span with the operation name "User Load"
    #   # and which has a log entry with event 'error'.
    #   expect(tracer).to have_span("User Load").with_logs(event: 'error')
    #
    #   # Passes if the tracer traced any span which has any entry in a baggage
    #   expect(tracer).to have_span.with_baggae
    #
    #   # Passes if the tracer traced span with the operation name "User Load"
    #   # and which has a baggage with 'account_id' => '1'
    #   expect(tracer).to have_span("User Load").with_baggae('account_id' => '1')
    #
    #   # Passes if the tracer traced any span which has a parent
    #   expect(tracer).to have_span.with_parent
    #
    #   # Passes if the tracer traced any span which has root_span as a parent
    #   expect(tracer).to have_span.child_of(root_span)
    #
    #   # Passes if the tracer traced span with the operation name "User Load"
    #   # and which has a parent span with operation name "Authentication".
    #   expect(tracer).to have_span("User Load").child_of("Authentication")
    #
    #   # Passes if the tracer traced span with the operation name "User Load"
    #   # which has a tag 'component' => 'ActiveRecord',
    #   # has any log entry,
    #   # has a baggage with 'account_id' => '1',
    #   # and is child of a span with operation name "Authentication".
    #   expect(tracer).to have_span("User Load")
    #                     .with_tags('component' => 'ActiveRecord')
    #                     .with_logs
    #                     .with_baggage('account_id' => '1')
    #                     .child_of("Authentication")
    #
    # @param [String] operation_name operation name of a searched span
    # @return [HaveSpan]
    #
    # @see HaveSpan#in_progress
    # @see HaveSpan#started
    # @see HaveSpan#finished
    # @see HaveSpan#with_tags
    # @see HaveSpan#with_logs
    # @see HaveSpan#with_baggage
    # @see HaveSpan#with_parent
    # @see HaveSpan#child_of
    def have_span(operation_name = anything)
      Tracing::Matchers::HaveSpan.new(operation_name)
    end
  end
end

RSpec.configure do |config|
  config.include Tracing::Matchers
end
