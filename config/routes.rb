Rails.application.routes.draw do
  root 'application#hello'
  
  post 'electronic_files/download', to: 'electronic_files#download'
  post 'electronic_files/upload', to: 'electronic_files#upload'
  resources :electronic_files
  

end
