require "spec_helper"

RSpec.describe Tracing::Matchers::Span::HaveBaggage do
  let(:tracer) { Test::Tracer.new }

  describe "success cases" do
    let(:span) do
      tracer.start_span("test").set_baggage_item("tag", "value")
    end

    it "passes if includes any baggage item" do
      expect(span).to have_baggage
    end

    it "passes if includes expected baggage items" do
      expect(span).to have_baggage("tag", "value")
      expect(span).to have_baggage("tag" => "value")
    end

    it "passes if 'matches' a baggage item" do
      expect(span).to have_baggage("tag", /value/)
      expect(span).to have_baggage("tag" => /value/)
    end
  end

  describe "failure cases" do
    let(:span) do
      tracer.start_span("test")
    end

    it "fails if there is no baggage at all" do
      expect {
        expect(span).to have_baggage
      }.to fail_with("expected any baggage")
    end

    it "fails if expected baggage item is missing" do
      span.set_baggage_item("tag1", "value1")
      expect {
        expect(span).to have_baggage("tag", "value")
      }.to fail_with('expected {"tag"=>"value"} baggage, got {"tag1"=>"value1"}')
    end

    it "fails if expected baggage item got different value" do
      span.set_baggage_item("tag1", "value1")
      expect {
        expect(span).to have_baggage("tag1", "value2")
      }.to fail_with('expected {"tag1"=>"value2"} baggage, got {"tag1"=>"value1"}')
    end

    it "fails if expected baggage item got different value, and doesn't match regex" do
      span.set_baggage_item("tag1", "invalid1")
      expect {
        expect(span).to have_baggage("tag1", /value/)
      }.to fail_with('expected {"tag1"=>/value/} baggage, got {"tag1"=>"invalid1"}')
    end
  end

  describe "description generation" do
    let(:span) do
      tracer.start_span("test").set_baggage_item("tag", "value")
    end

    it "generates description" do
      expect(span).to have_baggage
      expect(RSpec::Matchers.generated_description).to eq "should have baggage"
    end

    it "generates description with expected baggage values" do
      expect(span).to have_baggage("tag", "value")
      expect(RSpec::Matchers.generated_description).to eq 'should have baggage {"tag"=>"value"}'

      expect(span).to have_baggage("tag" => "value")
      expect(RSpec::Matchers.generated_description).to eq 'should have baggage {"tag"=>"value"}'
    end
  end
end
