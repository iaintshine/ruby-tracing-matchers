require "spec_helper"
require "pry"

RSpec.describe Tracing::Matchers::Span::BeChildOf do
  let(:tracer) { Test::Tracer.new }

  describe "success cases" do
    let(:parent) { tracer.start_span("parent operation") }
    let(:span) { tracer.start_span("child operation", child_of: parent) }

    it "passes if is a child of any span" do
      expect(span).to have_parent
    end

    it "passes if is a child of a specific span" do
      expect(span).to be_child_of("parent operation")
      expect(span).to be_child_of(parent)
      expect(span).to be_child_of(parent.context)
    end

    it "passes if is a child of a specific span context" do
      extracted_context = Test::SpanContext.root
      followup_span = tracer.start_span("follow up", child_of: extracted_context)

      expect(followup_span).to have_parent
      expect(followup_span).to be_child_of(extracted_context)
    end
  end

  describe "failure cases" do
    let(:span) do
      tracer.start_span("test")
    end

    it "fails if there is no parent" do
      expect {
        expect(span).to have_parent
      }.to fail_with("expected a parent")
    end

    it "fails if span has no parent but one is expected" do
      tracer.start_span("parent operation")

      expect {
        expect(span).to be_child_of("parent operation")
      }.to fail_with('expected a span with operation name "parent operation" as the parent, got nothing')
    end

    it "fails if span has no parent, one is expected but doesn't exist" do
      expect {
        expect(span).to be_child_of("parent operation")
      }.to fail_with('expected a span with operation name "parent operation" as the parent, got nothing')
    end

    it "fails if expected parent is different then expected" do
      parent = tracer.start_span("parent operation")
      different_parent = tracer.start_span("different parent operation")
      span = tracer.start_span("child operation", child_of: different_parent)

      expect {
        expect(span).to be_child_of("parent operation")
      }.to fail_with('expected a span with operation name "parent operation" as the parent, got a span with operation name "different parent operation"')

      expect {
        expect(span).to be_child_of(parent)
      }.to fail_with('expected the span with operation name "parent operation" as the parent, got a span with operation name "different parent operation"')

      expect {
        expect(span).to be_child_of(parent.context)
      }.to fail_with('expected the span context with id "' + parent.context.span_id + '" as the parent, got a span context with id "' + different_parent.context.span_id + '"')


      parent_context = Test::SpanContext.root
      different_parent_context = Test::SpanContext.root
      span = tracer.start_span("child operation", child_of: different_parent_context)

      expect {
        expect(span).to be_child_of("parent operation")
      }.to fail_with('expected a span with operation name "parent operation" as the parent, got a span context with id "' + different_parent_context.span_id + '"')

      expect {
        expect(span).to be_child_of(parent)
      }.to fail_with('expected the span with operation name "parent operation" as the parent, got a span context with id "' + different_parent_context.span_id + '"')

      expect {
        expect(span).to be_child_of(parent_context)
      }.to fail_with('expected the span context with id "' + parent_context.span_id + '" as the parent, got a span context with id "' + different_parent_context.span_id + '"')
    end
  end

  describe "description generation" do
    let(:parent) { tracer.start_span("parent operation") }
    let(:span) { tracer.start_span("child operation", child_of: parent) }

    it "generates description" do
      expect(span).to have_parent
      expect(RSpec::Matchers.generated_description).to eq "should have a parent"
    end

    it "generates description with expected parent" do
      expect(span).to be_child_of("parent operation")
      expect(RSpec::Matchers.generated_description).to eq 'should have a span with operation name "parent operation" as the parent'

      expect(span).to be_child_of(parent)
      expect(RSpec::Matchers.generated_description).to eq 'should have the span with operation name "parent operation" as the parent'

      expect(span).to be_child_of(parent.context)
      expect(RSpec::Matchers.generated_description).to eq 'should have the span context with id "' + parent.context.span_id + '" as the parent'
    end
  end
end
