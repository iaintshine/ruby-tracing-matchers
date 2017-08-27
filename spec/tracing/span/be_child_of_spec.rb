require "spec_helper"

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

    it "fails if expected parent is missing" do
      expect {
        expect(span).to be_child_of("parent operation")
      }.to fail_with('expected "parent operation" parent, got nothing')
    end

    it "fails if expected tag got different value" do
      parent = tracer.start_span("parent operation")
      different_parent = tracer.start_span("different parent operation")
      span = tracer.start_span("child operation", child_of: different_parent)

      expect {
        expect(span).to be_child_of("parent operation")
      }.to fail_with('expected "parent operation" parent, got "different parent operation"')

      expect {
        expect(span).to be_child_of(parent)
      }.to fail_with('expected "parent operation" parent, got "different parent operation"')

      expect {
        expect(span).to be_child_of(parent.context)
      }.to fail_with('expected span context with id "' + parent.context.span_id + '" parent, got "different parent operation"')
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
      expect(RSpec::Matchers.generated_description).to eq 'should have "parent operation" parent'

      expect(span).to be_child_of(parent)
      expect(RSpec::Matchers.generated_description).to eq 'should have "parent operation" parent'

      expect(span).to be_child_of(parent.context)
      expect(RSpec::Matchers.generated_description).to eq 'should have span context with id "' + parent.context.span_id + '" parent'
    end
  end
end
