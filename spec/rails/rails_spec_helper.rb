require 'spec_helper'
require 'combustion'
require 'arbre/railtie'

Combustion.path = 'spec/rails/stub_app'
Combustion.initialize! :action_controller, :action_view, :sprockets

require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'

RSpec.configure do |config|
  config.include Capybara::RSpecMatchers
end