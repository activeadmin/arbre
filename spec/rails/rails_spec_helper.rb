# frozen_string_literal: true
require 'rubygems'
require 'bundler/setup'

require 'combustion'

# Ensure that the rails plugin is installed
require 'arbre/railtie'

Combustion.path = 'spec/rails/stub_app'
Combustion.initialize! :action_controller,
                       :action_view

require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'

require 'spec_helper'

require 'rails/support/mock_person'

module AdditionalHelpers

  def protect_against_forgery?
    true
  end

  def form_authenticity_token(form_options: {})
    "AUTH_TOKEN"
  end

end

def mock_action_view(assigns = {})
  controller = ActionView::TestCase::TestController.new
  ActionView::Base.include(ActionView::Helpers)
  ActionView::Base.include(AdditionalHelpers)
  context = ActionView::LookupContext.new(ActionController::Base.view_paths)
  ActionView::Base.new(context, assigns, controller)
end

RSpec.configure do |config|
  config.include Capybara::RSpecMatchers
end
