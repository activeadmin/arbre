# frozen_string_literal: true
require "open3"
require "arbre/version"

RSpec.describe "gemspec sanity" do
  after do
    File.delete("arbre-#{Arbre::VERSION}.gem")
  end

  let(:build) do
    Bundler.with_original_env do
      Open3.capture3("gem build arbre")
    end
  end

  it "has no warnings" do
    expect(build[1]).not_to include("WARNING"), output
  end

  it "succeeds" do
    expect(build[2]).to be_success
  end
end
