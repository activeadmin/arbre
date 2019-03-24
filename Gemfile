source 'http://rubygems.org'

gemspec

gem 'rake'

group :test do
  gem 'rspec'
  gem 'pry'
end

group :tools do
  gem 'rubocop'
end

group :release do
  gem 'chandler'
end

group :rails do
  gem 'rails', '>= 5.0.0.1' # fixes CVE-2016-6316
  gem 'rspec-rails'
  gem 'combustion'
  gem 'capybara'
end
