require "spec_helper"

RSpec.describe Tracing::Matchers::HaveSpans do
  let(:tracer) { Test::Tracer.new }

  describe "success cases" do
    before do
      tracer.start_span("test")
      tracer.start_span("in progress")
      tracer.start_span("finished").finish
      root = tracer.start_span("root")
      tracer.start_span("child", child_of: root)

      span = tracer.start_span("rich", child_of: root)
      span.set_tag("tag", "value")
      span.set_baggage_item("baggage_item", "value")
      span.log(event: "test", "field1" => "value")
      span.finish
    end

    it "passes if general conditions are met" do
      expect(tracer).to have_span
      expect(tracer).to have_span.in_progress
      expect(tracer).to have_span.started
      expect(tracer).to have_span.finished
      expect(tracer).to have_span.with_tags
      expect(tracer).to have_span.with_logs
      expect(tracer).to have_span.with_baggage
      expect(tracer).to have_span.with_parent
    end

    it "passes if named span conditions are met" do
      expect(tracer).to have_span("test")
      expect(tracer).to have_span("in progress").in_progress
      expect(tracer).to have_span("in progress").started
      expect(tracer).to have_span("finished").finished
      expect(tracer).to have_span("rich").with_tags
      expect(tracer).to have_span("rich").with_logs
      expect(tracer).to have_span("rich").with_baggage
      expect(tracer).to have_span("child").with_parent
    end

    it "passes if named span specific conditions are met" do
      expect(tracer).to have_span("rich").with_tags("tag" => "value")
      expect(tracer).to have_span("rich").with_logs(event: "test", "field1" => "value")
      expect(tracer).to have_span("rich").with_baggage("baggage_item" => "value")
      expect(tracer).to have_span("child").child_of("root")
    end

    it "passes if multiple conditions are met" do
      expect(tracer).to have_span("rich")
        .finished
        .with_tags("tag" => "value")
        .child_of("root")
    end
  end

  describe "failure cases" do
    it "fails if there are no spans at all" do
      expect {
        expect(tracer).to have_span
      }.to fail_with("expected any span")

      expect {
        expect(tracer).to have_span.started
      }.to fail_with("expected any span started")

      expect {
        expect(tracer).to have_span.finished
      }.to fail_with("expected any span finished")
    end

    it "fails if there is no span with an operation name" do
      expect {
        expect(tracer).to have_span("Child Operation Name")
      }.to fail_with("expected 'Child Operation Name' span")
    end

    it "fails if general conditions are not met" do
      expect {
        expect(tracer).to have_span.with_tags
      }.to fail_with("expected any span with tags")

      expect {
        expect(tracer).to have_span.with_logs
      }.to fail_with("expected any span with logs")

      expect {
        expect(tracer).to have_span.with_baggage
      }.to fail_with("expected any span with baggage")

      expect {
        expect(tracer).to have_span.with_parent
      }.to fail_with("expected any span with parent")
    end

    it "fails if specific conditions are not met" do
      expect {
        expect(tracer).to have_span.with_tags("tag" => "value")
      }.to fail_with('expected any span with  tags {"tag"=>"value"}')

      expect {
        expect(tracer).to have_span.with_logs(event: "test", "field1" => "value")
      }.to fail_with('expected any span with logs {:event=>"test","field1"=>"value"}')

      expect {
        expect(tracer).to have_span.with_baggage("baggage_item" => "value")
      }.to fail_with('expected any span with baggage {"baggage_item"=>"value"}')

      expect {
        expect(tracer).to have_span.child_of("Root Operation Name")
      }.to fail_with("expected any span with parent 'Root Operation Name'")
    end

    it "generates description for multiple conditions" do
      expect(tracer).to have_span("Child Operation Name")
        .finished
        .with_tags("tag" => "value")
        .child_of("Root Operation Name")

      expect(RSpec::Matchers.generated_description).to eq 'should have "Child Operation Name" span finished with tags {"tag"=>"value"} with parent "Root Operation Name"'
    end
  end

  describe "description generation" do
    before do
      root = tracer.start_span("Root Operation Name")
      span = tracer.start_span("Child Operation Name", child_of: root)
      span.set_tag("tag", "value")
      span.set_baggage_item("baggage_item", "value")
      span.log(event: "test", "field1" => "value")
      span.finish
    end

    it "generates description" do
      expect(tracer).to have_span
      expect(RSpec::Matchers.generated_description).to eq "should have span"
    end

    it "generates description with operation name" do
      expect(tracer).to have_span("Child Operation Name")
      expect(RSpec::Matchers.generated_description).to eq "should have 'Child Operation Name' span"
    end

    it "generates description with state" do
      expect(tracer).to have_span.in_progress
      expect(RSpec::Matchers.generated_description).to eq "should have span started"

      expect(tracer).to have_span.started
      expect(RSpec::Matchers.generated_description).to eq "should have span started"

      expect(tracer).to have_spans.finished
      expect(RSpec::Matchers.generated_description).to eq "should have span finished"
    end

    it "generates description with general condition" do
      expect(tracer).to have_span.with_tags
      expect(RSpec::Matchers.generated_description).to eq "should have span with tags"

      expect(tracer).to have_span.with_logs
      expect(RSpec::Matchers.generated_description).to eq "should have span with logs"

      expect(tracer).to have_span.with_baggage
      expect(RSpec::Matchers.generated_description).to eq "should have span with baggage"

      expect(tracer).to have_span.with_parent
      expect(RSpec::Matchers.generated_description).to eq "should have span with parent"
    end

    it "generates description with specific condition" do
      expect(tracer).to have_span.with_tags("tag" => "value")
      expect(RSpec::Matchers.generated_description).to eq 'should have span with tags {"tag"=>"value"}'

      expect(tracer).to have_span.with_logs(event: "test", "field1" => "value")
      expect(RSpec::Matchers.generated_description).to eq 'should have span with logs {:event=>"test","field1"=>"value"}'

      expect(tracer).to have_span.with_baggage("baggage_item" => "value")
      expect(RSpec::Matchers.generated_description).to eq 'should have span with baggage {"baggage_item"=>"value"}'

      expect(tracer).to have_span.child_of("Root Operation Name")
      expect(RSpec::Matchers.generated_description).to eq "should have 'Child Operation Name' span with parent 'Root Operation Name'"
    end

    it "generates description for multiple conditions" do
      expect(tracer).to have_span("Child Operation Name")
        .finished
        .with_tags("tag" => "value")
        .child_of("Root Operation Name")

      expect(RSpec::Matchers.generated_description).to eq 'should have "Child Operation Name" span finished with tags {"tag"=>"value"} with parent "Root Operation Name"'
    end
  end
end
