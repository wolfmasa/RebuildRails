Rails.application.routes.draw do
 # # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :episodes
  root 'welcome#index'
  get 'update' => 'episodes#updateFromRss'
  get 'search/:word' => 'episodes#search'
  get 'search' => 'episodes#search'
end
