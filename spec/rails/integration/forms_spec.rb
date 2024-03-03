# frozen_string_literal: true
require 'rails/rails_spec_helper'

RSpec.describe "Forms" do

  let(:assigns){ {} }
  let(:helpers){ mock_action_view }
  let(:html) { form.to_s }

  describe "building a simple form for" do

    let(:form) do
      arbre do
        form_for MockPerson.new, url: "/" do |f|
          f.label :name
          f.text_field :name
        end
      end
    end

    it "builds a form" do
      expect(html).to have_css("form")
    end

    it "includes the hidden authenticity token" do
      expect(html).to have_field("authenticity_token", type: :hidden, with: "AUTH_TOKEN")
    end

    it "creates a label" do
      expect(html).to have_css("form label[for=mock_person_name]")
    end

    it "creates a text field" do
      expect(html).to have_css("form input[type=text]")
    end

  end

  describe "building a form with fields for" do

    let(:form) do
      arbre do
        form_for MockPerson.new, url: "/" do |f|
          f.label :name
          f.text_field :name
          f.fields_for :permission do |pf|
            pf.label :admin
            pf.check_box :admin
          end
        end
      end
    end

    it "renders nested label" do
      expect(html).to have_css("form label[for=mock_person_permission_admin]", text: "Admin")
    end

    it "renders nested input" do
      expect(html).to have_css("form input[type=checkbox][name='mock_person[permission][admin]']")
    end

    it "does not render a div for the proxy" do
      expect(html).to have_no_css("form div.fields_for_proxy")
    end

  end

  describe "forms with other elements" do
    let(:form) do
      arbre do
        form_for MockPerson.new, url: "/" do |f|

          div do
            f.label :name
            f.text_field :name
          end

          para do
            f.label :name
            f.text_field :name
          end

          div class: "permissions" do
            f.fields_for :permission do |pf|
              div class: "permissions_label" do
                pf.label :admin
              end
              pf.check_box :admin
            end
          end

        end
      end
    end

    it "nests elements" do
      expect(html).to have_css("form > p > label")
    end

    it "nests elements within fields for" do
      expect(html).to have_css("form > div.permissions > div.permissions_label label")
    end
  end

end
