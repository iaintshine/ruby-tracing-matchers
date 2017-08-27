require "spec_helper"

RSpec.describe Tracing::Matchers::Span::HaveTag do
  let(:tracer) { Test::Tracer.new }

  describe "success cases" do
    let(:span) do
      tracer.start_span("test").set_tag("tag", "value")
    end

    it "passes if includes any tag" do
      expect(span).to have_tag
    end

    it "passes if includes expected tag" do
      expect(span).to have_tag("tag", "value")
      expect(span).to have_tag("tag" => "value")
    end
  end

  describe "failure cases" do
    let(:span) do
      tracer.start_span("test")
    end

    it "fails if there are no tags at all" do
      expect {
        expect(span).to have_tag
      }.to fail_with("expected any tag")
    end

    it "fails if expected tag is missing" do
      span.set_tag("tag1", "value1")
      expect {
        expect(span).to have_tag("tag", "value")
      }.to fail_with('expected {"tag"=>"value"} tags, got {"tag1"=>"value1"}')
    end

    it "fails if expected tag got different value" do
      span.set_tag("tag1", "value1")
      expect {
        expect(span).to have_tag("tag1", "value2")
      }.to fail_with('expected {"tag1"=>"value2"} tags, got {"tag1"=>"value1"}')
    end
  end

  describe "description generation" do
    let(:span) do
      tracer.start_span("test").set_tag("tag", "value")
    end

    it "generates description" do
      expect(span).to have_tag
      expect(RSpec::Matchers.generated_description).to eq "should have tags"
    end

    it "generates description with expected tag values" do
      expect(span).to have_tag("tag", "value")
      expect(RSpec::Matchers.generated_description).to eq 'should have tags {"tag"=>"value"}'

      expect(span).to have_tag("tag" => "value")
      expect(RSpec::Matchers.generated_description).to eq 'should have tags {"tag"=>"value"}'
    end
  end
end
