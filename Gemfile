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
  gem 'parallel', '~> 1.28' # TODO: remove when dropping Ruby < 3.3 compatibility

  gem 'rubocop'
  gem 'rubocop-capybara'
  gem 'rubocop-packaging'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
end

group :rails do
  gem 'rails', '~> 8.1.0'
  gem 'json', '< 3.0' # TODO: relax this constraint when rails/rails#58601 will be released
  gem 'rspec-rails'
  gem 'combustion'
  gem 'capybara'
end
