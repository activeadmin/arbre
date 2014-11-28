require 'rubygems'
require 'bundler/setup'

require 'combustion'

Combustion.path = 'spec/rails/stub_app'
Combustion.initialize! :action_controller,
                       :action_view

require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'

require 'spec_helper'

require 'rails/support/mock_person'

# Ensure that the rails plugin is installed
require 'arbre/rails'

Rails.application.routes.draw do
  get 'test/:action', controller: "test"
end

module AdditionalHelpers

  def protect_against_forgery?
    true
  end

  def form_authenticity_token
    "AUTH_TOKEN"
  end

end

def mock_action_view(assigns = {})
  controller = ActionView::TestCase::TestController.new
  ActionView::Base.send :include, ActionView::Helpers
  ActionView::Base.send :include, AdditionalHelpers
  ActionView::Base.new(ActionController::Base.view_paths, assigns, controller)
end

RSpec.configure do |config|
  config.include Capybara::RSpecMatchers
end
