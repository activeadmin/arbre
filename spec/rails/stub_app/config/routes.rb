Rails.application.routes.draw do
  match 'test/:action', :controller => "test"
end