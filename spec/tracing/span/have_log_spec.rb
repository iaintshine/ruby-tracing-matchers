require "spec_helper"

RSpec.describe Tracing::Matchers::Span::HaveLog do
  let(:tracer) { Test::Tracer.new }

  describe "success cases" do
    let(:span) do
      span = tracer.start_span("test")
      span.log(event: "error", message: "error message")
      span
    end

    it "passes if includes any log entry" do
      expect(span).to have_log
    end

    it "passes if includes expected log entry" do
      expect(span).to have_log(event: "error")
      expect(span).to have_log(message: "error message")
      expect(span).to have_log(event: "error", message: "error message")
      expect(span).to have_log(event: "error", message: /message/)
    end
  end

  describe "failure cases" do
    let(:span) do
      tracer.start_span("test")
    end

    it "fails if there are no log entries at all" do
      expect {
        expect(span).to have_log
      }.to fail_with("expected any log entry")
    end

    it "fails if expected log entry is missing" do
      span.log(event: "warning")
      expect {
        expect(span).to have_log(event: "error")
      }.to fail_with('expected {:event=>"error"} log entry, got [{:event=>"warning"}]')

      expect {
        expect(span).to have_log(message: /description/)
      }.to fail_with('expected {:message=>/description/} log entry, got [{:event=>"warning"}]')
    end
  end

  describe "description generation" do
    let(:span) do
      span = tracer.start_span("test")
      span.log(event: "error", message: "error message")
      span
    end

    it "generates description" do
      expect(span).to have_log
      expect(RSpec::Matchers.generated_description).to eq "should have log entry"
    end

    it "generates description with expected tag values" do
      expect(span).to have_log(event: "error")
      expect(RSpec::Matchers.generated_description).to eq 'should have log entry {:event=>"error"}'
    end
  end
end
