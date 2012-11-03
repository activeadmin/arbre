require 'rails/rails_spec_helper'

describe "Building forms" do
  let(:model_stub_class) do
    Class.new do
      extend ActiveModel::Naming
      attr_accessor :name

      def self.name
        "MockPerson"
      end

      def persisted?
        false
      end

      def to_key
        []
      end
    end
  end

  let(:view_stub_class) do
    Class.new(ActionView::Base) do
      include ActionView::Helpers

      def protect_against_forgery?
        true
      end

      def form_authenticity_token
        "AUTH_TOKEN"
      end
    end
  end

  let(:model_stub) { model_stub_class.new }
  let(:assigns) { {model_stub: model_stub} }
  let(:helpers) { view_stub_class.new(ActionController::Base.view_paths, assigns, controller) }
  let(:controller) { ActionView::TestCase::TestController.new }
  let(:html) { form.to_s }

  describe "building a simple form for" do

    let(:form) do
      arbre do
        form_for model_stub, :url => "/" do |f|
          f.label :name
          f.text_field :name
        end
      end
    end

    it "should build a form" do
      html.should have_selector("form")
    end

    it "should include the hidden authenticity token" do
      html.should have_selector("form input[type=hidden][name=authenticity_token]")
    end

    it "should create a label" do
      html.should have_selector("form label[for=mock_person_name]")
    end

    it "should create a text field" do
      html.should have_selector("form input[type=text]")
    end

  end

  describe "building a form with fields for" do

    let(:form) do
      arbre do
        form_for model_stub, :url => "/" do |f|
          f.label :name
          f.text_field :name
          f.fields_for :permission do |pf|
            pf.label :admin
            pf.check_box :admin
          end
        end
      end
    end

    it "should render nested label" do
      html.should have_selector("form label[for=mock_person_permission_admin]", :text => "Admin")
    end

    it "should render nested label" do
      html.should have_selector("form input[type=checkbox][name='mock_person[permission][admin]']")
    end

    it "should not render a div for the proxy" do
      html.should_not have_selector("form div.fields_for_proxy")
    end

  end

  describe "forms with other elements" do
    let(:form) do
      arbre do
        form_for model_stub, :url => "/" do |f|

          div do
            f.label :name
            f.text_field :name
          end

          para do
            f.label :name
            f.text_field :name
          end

          div :class => "permissions" do
            f.fields_for :permission do |pf|
              div :class => "permissions_label" do
                pf.label :admin
              end
              pf.check_box :admin
            end
          end

        end
      end
    end

    it "should correctly nest elements" do
      html.should have_selector("form > p > label")
    end

    it "should correnctly nest elements within fields for" do
      html.should have_selector("form > div.permissions > div.permissions_label label")
    end
  end
end
