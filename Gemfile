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
  gem 'rails', '~> 6.0.2', github: 'rails/rails', branch: '6-0-stable'
  gem 'rspec-rails'
  gem 'combustion'
  gem 'capybara'
end
