# frozen_string_literal: true
require 'spec_helper'

Combustion.path = 'spec/rails/stub_app'
Combustion.initialize! :action_controller, :action_view do
  if Rails.gem_version >= Gem::Version.new("7.1.0")
    config.active_support.cache_format_version = 7.1
  end
end

require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'

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
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end
