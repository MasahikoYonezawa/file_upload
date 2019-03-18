Rails.application.routes.draw do
  root 'application#hello'
  resources :electronic_files
  post 'electronic_files/upload', to: 'electronic_files#upload'

end
