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

module ArbreRailsHelpers
  # Returns a view to use as the helpers of an Arbre context.
  #
  # The view class is a fresh subclass for each call, so the overrides
  # below never leak into the views that real requests render with.
  def mock_action_view(assigns = {})
    view_class = Class.new(ActionView::Base.with_empty_template_cache) do
      def protect_against_forgery?
        true
      end

      def form_authenticity_token(form_options: {})
        "AUTH_TOKEN"
      end
    end
    controller = ActionView::TestCase::TestController.new
    lookup_context = ActionView::LookupContext.new(ActionController::Base.view_paths)
    view_class.new(lookup_context, assigns, controller)
  end
end

RSpec.configure do |config|
  config.include Capybara::RSpecMatchers
  config.include ArbreRailsHelpers
end
