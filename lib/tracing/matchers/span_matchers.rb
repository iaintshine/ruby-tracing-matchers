require "tracing/matchers/span/have_tag"

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
  end
end
