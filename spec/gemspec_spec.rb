# frozen_string_literal: true
require "spec_helper"
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

  it "succeeds" do
    expect(build[2]).to be_success
  end
end
