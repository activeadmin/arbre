# frozen_string_literal: true
source 'http://rubygems.org'

gemspec

gem 'rake'

group :test do
  gem 'rspec'
  gem 'simplecov', require: false
  gem 'simplecov-cobertura'
  gem 'pry'
end

group :rubocop do
  gem 'rubocop'
  gem 'rubocop-packaging'
end

group :rails do
  gem 'rails', '~> 7.0.2'
  gem 'rspec-rails'
  gem 'combustion'
  gem 'capybara'
end
