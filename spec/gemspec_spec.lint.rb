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
    output = build[1]

    if RUBY_ENGINE == "jruby"
      annoying_jruby_warnings = [
        /WARNING: An illegal reflective access operation has occurred/,
        /WARNING: Illegal reflective access by org.jruby.ext.openssl.SecurityHelper \(file:.*\/jopenssl\.jar\) to field java\.security\.MessageDigest\.provider/,
        /WARNING: Please consider reporting this to the maintainers of org\.jruby\.ext\.openssl\.SecurityHelper/,
        /WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations/,
        /WARNING: All illegal access operations will be denied in a future release/
      ]

      output = output.split("\n").reject { |line| annoying_jruby_warnings.any? { |warning| warning.match?(line) } }.join("\n")
    end

    expect(output).not_to include("WARNING"), output
  end

  it "succeeds" do
    expect(build[2]).to be_success
  end
end
