require "spec_helper"

RSpec.describe Tracing::Matchers do
  it "has a version number" do
    expect(Tracing::Matchers::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
