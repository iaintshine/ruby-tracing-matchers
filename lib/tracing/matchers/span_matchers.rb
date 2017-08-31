require "tracing/matchers/span/have_tag"
require "tracing/matchers/span/have_log"
require "tracing/matchers/span/have_baggage"
require "tracing/matchers/span/be_child_of"
require "tracing/matchers/span/follow_after"

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

    # The `be_child_of` matcher tests that the span/span context is a child of some other span/span context.
    # @example
    #
    #   # Passes if span is a child of any span
    #   expect(span).to have_parent
    #
    #   # Passes if span is a child of a specific span context
    #   expect(span).to be_child_of("parent operation")
    #   expect(span).to be_child_of(parent_span)
    #   expect(span).to be_child_of(parent_span_context)
    #
    # @return [HaveBaggage]
    def be_child_of(parent = :any)
      Tracing::Matchers::Span::BeChildOf.new(parent)
    end
    alias :have_parent :be_child_of

    # The `follow_after` matcher tests that the span follows after some other span.
    # @example
    #
    #   # Passes if span follows after spcific span
    #   expect(span).to be_child_of("previous operation")
    #   expect(span).to be_child_of(previous_span)
    #
    # @param [String, Span] previous expected span to follow after
    # @return [FollowAfter]
    def follow_after(previous)
      Tracing::Matchers::Span::FollowAfter.new(previous)
    end
  end
end
