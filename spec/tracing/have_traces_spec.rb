require "spec_helper"

RSpec.describe Tracing::Matchers::HaveTraces do
  let(:tracer) { Test::Tracer.new }

  describe "success cases" do
    it "passes if includes any trace" do
      tracer.start_span("test")

      expect(tracer).to have_traces
    end

    it "passes if includes exactly N traces" do
      span1 = tracer.start_span("test1")
      tracer.start_span("test2", child_of: span1)
      tracer.start_span("test3")

      expect(tracer).to have_traces(2)
    end

    it "passes if there is any trace started" do
      tracer.start_span("test")

      expect(tracer).to have_traces.started
    end

    it "passes if there is exactly N traces started" do
      span1 = tracer.start_span("test1")
      tracer.start_span("test2", child_of: span1)
      tracer.start_span("test3")

      expect(tracer).to have_traces(2).started
    end

    it "passes if there is any finished trace" do
      tracer.start_span("test").finish

      expect(tracer).to have_traces.finished
    end

    it "passes if there is exactly N finished traces" do
      span1 = tracer.start_span("test1")
      tracer.start_span("test2", child_of: span1).finish
      span1.finish
      tracer.start_span("test3").finish

      expect(tracer).to have_traces(2).started
    end

    it "is possible to chain started and finished" do
      tracer.start_span("test").finish

      expect(tracer).to have_traces.started.finished
    end
  end

  describe "failure cases" do
    it "fails if there are no traces at all" do
      expect {
        expect(tracer).to have_traces
      }.to fail_with("expected any trace")

      expect {
        expect(tracer).to have_traces.started
      }.to fail_with("expected any trace started")

      expect {
        expect(tracer).to have_traces.finished
      }.to fail_with("expected any trace finished")
    end

    it "fails if target has > n traces" do
      tracer.start_span("test1").finish
      tracer.start_span("test2").finish
      tracer.start_span("test3").finish

      expect {
        expect(tracer).to have_traces(2)
      }.to fail_with("expected 2 traces, got 3")

      expect {
        expect(tracer).to have_traces(2).started
      }.to fail_with("expected 2 traces started, got 3")

      expect {
        expect(tracer).to have_traces(2).finished
      }.to fail_with("expected 2 traces finished, got 3")
    end

    it "fails if target has < n traces" do
      tracer.start_span("test1").finish
      tracer.start_span("test2").finish

      expect {
        expect(tracer).to have_traces(3)
      }.to fail_with("expected 3 traces, got 2")

      expect {
        expect(tracer).to have_traces(3).started
      }.to fail_with("expected 3 traces started, got 2")

      expect {
        expect(tracer).to have_traces(3).finished
      }.to fail_with("expected 3 traces finished, got 2")
    end

    it "fails if target has no trace finished" do
      root_span = tracer.start_span("root")
      tracer.start_span("child", child_of: root_span).finish

      expect {
        expect(tracer).to have_traces.finished
      }.to fail_with("expected any trace finished")
    end
  end

  describe "description generation" do
    before { tracer.start_span("test").finish }

    it "generates description" do
      expect(tracer).to have_traces
      expect(RSpec::Matchers.generated_description).to eq "should have traces"
    end

    it "generates description with started" do
      expect(tracer).to have_traces.started
      expect(RSpec::Matchers.generated_description).to eq "should have traces started"
    end

    it "generates description with finished" do
      expect(tracer).to have_traces.finished
      expect(RSpec::Matchers.generated_description).to eq "should have traces finished"
    end

    it "generates description with N spans" do
      expect(tracer).to have_traces(1)
      expect(RSpec::Matchers.generated_description).to eq "should have exactly 1 traces"

      expect(tracer).to have_traces(1).started
      expect(RSpec::Matchers.generated_description).to eq "should have exactly 1 traces started"

      expect(tracer).to have_traces(1).finished
      expect(RSpec::Matchers.generated_description).to eq "should have exactly 1 traces finished"
    end
  end
end
