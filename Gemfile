# frozen_string_literal: true
source 'http://rubygems.org'

gemspec

gem 'rake'

group :test do
  gem 'rspec'
  gem 'pry'
end

group :tools do
  gem 'rubocop'
  gem 'rubocop-packaging'
end

group :release do
  gem 'chandler'
end

group :rails do
  gem 'rails', '~> 6.1.a'
  gem 'rspec-rails'
  gem 'combustion'
  gem 'capybara'
end
