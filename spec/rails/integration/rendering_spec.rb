require 'rails/rails_spec_helper'

ARBRE_VIEWS_PATH = File.expand_path("../../templates", __FILE__)

class TestController < ActionController::Base
  append_view_path ARBRE_VIEWS_PATH

  def render_empty
    render "arbre/empty"
  end

  def render_simple_page
    render "arbre/simple_page"
  end

  def render_partial
    render "arbre/page_with_partial"
  end

  def render_erb_partial
    render "arbre/page_with_erb_partial"
  end

  def render_with_instance_variable
    @my_instance_var = "From Instance Var"
    render "arbre/page_with_assignment"
  end

  def render_partial_with_instance_variable
    @my_instance_var = "From Instance Var"
    render "arbre/page_with_arb_partial_and_assignment"
  end
end


describe TestController, "Rendering with Arbre", type: :request do
  let(:body){ response.body }

  it "should render the empty template" do
    get "/test/render_empty"
    expect(response).to be_success
  end

  it "should render a simple page" do
    get "/test/render_simple_page"
    expect(response).to be_success
    expect(body).to have_selector("h1", text: "Hello World")
    expect(body).to have_selector("p", text: "Hello again!")
  end

  it "should render an arb partial" do
    get "/test/render_partial"
    expect(response).to be_success
    expect(body).to eq <<-EOS
<h1>Before Partial</h1>
<p>Hello from a partial</p>
<h2>After Partial</h2>
EOS
  end

  it "should render an erb (or other) partial" do
    get "/test/render_erb_partial"
    expect(response).to be_success
    expect(body).to eq <<-EOS
<h1>Before Partial</h1>
<p>Hello from an erb partial</p>
<h2>After Partial</h2>
EOS
  end

  it "should render with instance variables" do
    get "/test/render_with_instance_variable"
    expect(response).to be_success
    expect(body).to have_selector("h1", text: "From Instance Var")
  end

  it "should render an arbre partial with assignments" do
    get "/test/render_partial_with_instance_variable"
    expect(response).to be_success
    expect(body).to have_selector("p", text: "Partial: From Instance Var")
  end

end
