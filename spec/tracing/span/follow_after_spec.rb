require "spec_helper"
require "pry"

RSpec.describe Tracing::Matchers::Span::FollowAfter do
  let(:tracer) { Test::Tracer.new }

  describe "success cases" do
    let(:span) { tracer.start_span("next operation") }

    it "passes if is a span follows after a specific span" do
      previous = tracer.start_span("previous operation")

      expect(span).to follow_after("previous operation")
      expect(span).to follow_after(previous)
    end
  end

  describe "failure cases" do
    let(:span) do
      tracer.start_span("test")
    end

    it "fails if previous span doesn't exist" do
      expect {
        expect(span).to follow_after("previous operation")
      }.to fail_with('expected a span with operation name "test" to follow after a span with operation name "previous operation"')
    end

    it "fails if expected parent is different then expected" do
      previous_span = tracer.start_span("previous operation")
      next_span = tracer.start_span("next operation")

      expect {
        expect(previous_span).to follow_after("next operation")
      }.to fail_with('expected a span with operation name "previous operation" to follow after a span with operation name "next operation"')

      expect {
        expect(previous_span).to follow_after(next_span)
      }.to fail_with('expected a span with operation name "previous operation" to follow after the span with operation name "next operation"')
    end
  end

  describe "description generation" do
    let(:span) { tracer.start_span("next operation") }

    it "generates description with expected previous" do
      previous = tracer.start_span("previous operation")

      expect(span).to follow_after("previous operation")
      expect(RSpec::Matchers.generated_description).to eq 'should follow after a span with operation name "previous operation"'

      expect(span).to follow_after(previous)
      expect(RSpec::Matchers.generated_description).to eq 'should follow after the span with operation name "previous operation"'
    end
  end
end
