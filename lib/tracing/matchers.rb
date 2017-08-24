require "tracing/matchers/version"
require "tracing/matchers/have_traces"
require "tracing/matchers/have_span"

module Tracing
  module Matchers
    def have_traces(n = anything)
      Tracing::Matchers::HaveTraces.new(n)
    end

    def have_span(operation_name = anything)
      Tracing::Matchers::HaveSpan.new(operation_name)
    end
  end
end

RSpec.configure do |config|
  config.include Tracing::Matchers
end
