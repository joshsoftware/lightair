Light::Engine.routes.draw do
  mount RedactorRails::Engine => '/redactor_rails'
  get '/users/subscribe', to: 'users#subscribe', as: 'subscribe'
  get '/users/unsubscribe', to: 'users#unsubscribe', as: 'unsubscribe'
  delete '/users/remove', to: 'users#remove', as: 'remove'

  get '/auth/:provider/callback', to: 'spreadsheets#new',    as: 'google_spreadsheet'
  get '/auth/failure',            to: 'spreadsheets#failure'

  match 'users/import', to: 'users#import', via: [:get, :post]
  resources :newsletters do
    member do
      get 'test', to: 'newsletters#test_mail', as: 'test_mail'
      post 'send', to: 'newsletters#send_newsletter', as: 'send'
      post 'sendtest', to: 'newsletters#send_test_mail', as: 'send_test_mail'
    end
  end
  
  resources :users, :user_mailer, :spreadsheets

  root :to => 'newsletters#index'


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

