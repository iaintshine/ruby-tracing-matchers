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

    # @param [String] operation_name
    # @return [HaveSpan]
    def have_span(operation_name = anything)
      Tracing::Matchers::HaveSpan.new(operation_name)
    end
  end
end

RSpec.configure do |config|
  config.include Tracing::Matchers
end
