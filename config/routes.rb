Rails.application.routes.draw do
  root "files#index"
  resources :google_authenticates
end
