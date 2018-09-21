source 'http://rubygems.org'

gemspec

gem 'mime-types', '~> 2.6', platforms: :ruby_19

gem 'rake'

group :test do
  gem 'rspec'
  gem 'rack'
  gem 'pry'
end

group :rails do
  gem 'rails', '>= 5.0.0.1' # fixes CVE-2016-6316
  gem 'rspec-rails'
  gem 'combustion'
  gem 'capybara'
end
