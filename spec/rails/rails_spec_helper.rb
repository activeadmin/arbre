require 'spec_helper'
require 'combustion'

Combustion.path = 'spec/rails/stub_app'
Combustion.initialize! :action_controller, :action_view, :sprockets

require 'arbre/rails'
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'

RSpec.configure do |config|
  config.include Capybara::RSpecMatchers
end