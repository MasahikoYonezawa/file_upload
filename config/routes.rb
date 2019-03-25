Rails.application.routes.draw do
  root 'application#hello'
  
  post 'electronic_files/download', to: 'electronic_files#download'
  post 'electronic_files/upload', to: 'electronic_files#upload'
  post 'electronic_files/copy', to: 'electronic_files#copy'
  resources :electronic_files
  

end
