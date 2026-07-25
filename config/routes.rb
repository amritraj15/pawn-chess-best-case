Rails.application.routes.draw do
  get "/prices/:symbol", to: "prices#show"

resources :games do
  post :move, on: :member
end
end
