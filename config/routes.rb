require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    namespace :v1 do
      post "auth/sign_up", to: "auth#sign_up"
      post "auth/sign_in", to: "auth#sign_in"
      get  "quotes/:tag",  to: "quotes#show"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
