require "tracing/matchers/span/have_tag"
require "tracing/matchers/span/have_log"
require "tracing/matchers/span/have_baggage"

module Tracing
  module Matchers
    # The `have_tag` matcher tests that the span includes tags.
    # @example
    #
    #   # Passes if span have any tag
    #   expect(span).to have_tag
    #
    #   # Passes if span includes a tag with "tag" key, and "value" value
    #   expect(span).to have_tag("key", "value")
    #   expect(span).to have_tag("key" => "value")
    #
    # @return [HaveTag]
    def have_tag(*args)
      Tracing::Matchers::Span::HaveTag.new(*args)
    end
    alias :have_tags :have_tag

    # The `have_log` matcher tests that the span includes a tag.
    # @example
    #
    #   # Passes if span have any log
    #   expect(span).to have_log
    #
    #   # Passes if span includes a log entry with event: "error"
    #   expect(span).to have_log(event: "error")
    #
    # @return [HaveTag]
    def have_log(**fields)
      Tracing::Matchers::Span::HaveLog.new(**fields)
    end
    alias :have_logs :have_log

    # The `have_baggage` matcher tests that the span/span context includes baggage.
    # @example
    #
    #   # Passes if span have any baggage item
    #   expect(span).to have_baggage
    #
    #   # Passes if span includes a baggage item with "tag" key, and "value" value
    #   expect(span).to have_baggage("key", "value")
    #   expect(span).to have_baggage("key" => "value")
    #
    # @return [HaveBaggage]
    def have_baggage(*args)
      Tracing::Matchers::Span::HaveBaggage.new(*args)
    end
    alias :have_baggage_item :have_baggage
  end
end
