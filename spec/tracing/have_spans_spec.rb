require "spec_helper"

RSpec.describe Tracing::Matchers::HaveSpans do
  let(:tracer) { Test::Tracer.new }

  describe "success cases" do
    it "passes if includes any span" do
      tracer.start_span("test")

      expect(tracer).to have_spans
    end

    it "passes if includes exactly N spans" do
      tracer.start_span("test1")
      tracer.start_span("test2")

      expect(tracer).to have_spans(2)
    end

    it "passes if there is any started span" do
      tracer.start_span("test")

      expect(tracer).to have_spans.started
    end

    it "passes if there is exactly N started spans" do
      tracer.start_span("test1")
      tracer.start_span("test2")

      expect(tracer).to have_spans(2).started
    end

    it "passes if there is any finished span" do
      tracer.start_span("test").finish

      expect(tracer).to have_spans.finished
    end

    it "passes if there is exactly N finished spans" do
      tracer.start_span("test1").finish
      tracer.start_span("test2").finish

      expect(tracer).to have_spans(2).started
    end

    it "is possible to chain started and finished" do
      tracer.start_span("test").finish

      expect(tracer).to have_spans.started.finished
    end
  end

  describe "failure cases" do
    it "fails if there are no traces at all" do
      expect {
        expect(tracer).to have_spans
      }.to fail_with("expected any span")

      expect {
        expect(tracer).to have_spans.started
      }.to fail_with("expected any span started")

      expect {
        expect(tracer).to have_spans.finished
      }.to fail_with("expected any span finished")
    end

    it "fails if target has > n spans" do
      tracer.start_span("test1").finish
      tracer.start_span("test2").finish
      tracer.start_span("test3").finish

      expect {
        expect(tracer).to have_spans(2)
      }.to fail_with("expected 2 spans, got 3")

      expect {
        expect(tracer).to have_spans(2).started
      }.to fail_with("expected 2 spans started, got 3")

      expect {
        expect(tracer).to have_spans(2).finished
      }.to fail_with("expected 2 spans finished, got 3")
    end

    it "fails if target has < n spans" do
      tracer.start_span("test1").finish
      tracer.start_span("test2").finish

      expect {
        expect(tracer).to have_spans(3)
      }.to fail_with("expected 3 spans, got 2")

      expect {
        expect(tracer).to have_spans(3).started
      }.to fail_with("expected 3 spans started, got 2")

      expect {
        expect(tracer).to have_spans(3).finished
      }.to fail_with("expected 3 spans finished, got 2")
    end
  end

  describe "description generation" do
    before { tracer.start_span("test").finish }

    it "generates description" do
      expect(tracer).to have_spans
      expect(RSpec::Matchers.generated_description).to eq "should have traces"
    end

    it "generates description with started" do
      expect(tracer).to have_spans.started
      expect(RSpec::Matchers.generated_description).to eq "should have traces started"
    end

    it "generates description with finished" do
      expect(tracer).to have_spans.finished
      expect(RSpec::Matchers.generated_description).to eq "should have traces finished"
    end

    it "generates description with N spans" do
      expect(tracer).to have_spans(1)
      expect(RSpec::Matchers.generated_description).to eq "should have exactly 1 traces"

      expect(tracer).to have_spans(1).started
      expect(RSpec::Matchers.generated_description).to eq "should have exactly 1 traces started"

      expect(tracer).to have_spans(1).finished
      expect(RSpec::Matchers.generated_description).to eq "should have exactly 1 traces finished"
    end
  end
end
