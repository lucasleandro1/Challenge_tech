Rails.application.routes.draw do
  devise_for :users

  namespace :api do
    namespace :v1 do
      get "quotes/:tag", to: "quotes#show"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
