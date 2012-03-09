require 'rails/rails_spec_helper'
require 'active_model'


class MockPerson
  extend ActiveModel::Naming

  attr_accessor :name

  def persisted?
    false
  end

  def to_key
    []
  end
end

describe "Building forms" do

  let(:assigns){ {} }
  let(:helpers){ mock_action_view }
  let(:html) { form.to_s }

  describe "building a simple form for" do

    let(:form) do
      arbre do
        form_for MockPerson.new, :url => "/" do |f|
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
        form_for MockPerson.new, :url => "/" do |f|
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
        form_for MockPerson.new, :url => "/" do |f|

          div do
            f.label :name
            f.text_field :name
          end

          para do
            f.label :name
            f.text_field :name
          end

        end
      end
    end

    it "should correctly nest elements" do
      html.should have_selector("form > p > label")
    end
  end


end
