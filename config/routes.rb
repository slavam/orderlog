Orderlog::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  resources :workers do
    collection do
      get :my_show
    end
  end

  resources :subdivisions do
    collection do
      get :show_branches_of_division
    end
  end

  resources :wares
  resources :ware_types
  resources :assets
  resources :services
  resources :states
  resources :claim_lines
  resources :claims do
    collection do
      get :delete_claim_line, :show_claim_on_agreement, :change_budget_item, :delete_claim, :claim_state_change, :claim_history,
        :edit_quantity, :edit_description, :get_consolidated_climes_params, :show_claim_consolidated, :show_claim_lines_by_budget_item
#      post :claim_state_change
    end
  end
  resources :asset_groups

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'workers#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
