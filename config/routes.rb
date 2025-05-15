Rails.application.routes.draw do
  post "/forgot_password", to: "password_resets#create"
  patch "/reset_password/:token", to: "password_resets#update", as: :reset_password
  post "/signup", to: "registrations#create"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  match "*unmatched", to: "errors#not_found", via: :all
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
