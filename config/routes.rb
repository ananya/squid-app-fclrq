Rails.application.routes.draw do
  post 'questions/ask' => 'questions#ask'

  root "homepage#index"
end
