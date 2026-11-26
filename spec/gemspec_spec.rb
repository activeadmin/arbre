# frozen_string_literal: true
require "spec_helper"
require "fileutils"
require "open3"
require "tmpdir"

RSpec.describe "Gemspec" do
  let(:output_dir) { Dir.mktmpdir }
  let(:gem_path) { File.join(output_dir, "arbre.gem") }
  let(:build) do
    Bundler.with_original_env do
      Open3.capture3("gem", "build", "arbre.gemspec", "--output", gem_path)
    end
  end

  after do
    FileUtils.remove_entry(output_dir)
  end

  it "succeeds" do
    expect(build[2]).to be_success
    expect(File).to exist(gem_path)
  end
end
