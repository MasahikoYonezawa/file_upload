Rails.application.routes.draw do
  root 'application#hello'
  resources :electronic_files
end
