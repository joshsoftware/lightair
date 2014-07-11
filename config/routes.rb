Rails.application.routes.draw do
=begin
  get '/home/sheets',              to: 'home#add_from_google',  as: 'add_from_google'
  get '/auth/:provider/callback',  to: 'callbacks#omniauth'
  get '/linkedin',                 to: 'callbacks#linkedin',    as: 'linkedin'
  get '/callbacks/sheet/:id',      to: 'callbacks#setSheet',    as: 'set_sheet' 
  get '/callbacks/index',          to: 'callbacks#index',       as: 'callback_index' 
  get '/callbacks/update/:id',     to: 'callbacks#update',       as: 'callback_update'
=end
  get '/auth/:provider/callback',  to: 'spreadsheets#new'
  resources :users, :newsletters, :home, :spreadsheets

  root :to => 'home#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
