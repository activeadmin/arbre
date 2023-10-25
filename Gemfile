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
  gem 'rubocop-performance'
end

group :rails do
  gem 'rails', '~> 7.1.0'
  gem 'rspec-rails'
  gem 'combustion'
  gem 'capybara'
end
