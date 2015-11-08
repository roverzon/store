Rails.application.routes.draw do
  devise_for :users
  namespace :admin do
    resources :products
    resources :orders do 
      member do 
        post :cancel
        post :ship
        post :shipped
        post :return
      end  
    end 
  end

  namespace :account do
    resources :orders
  end

  resources :products do
    member do
      post :add_to_cart
    end
  end

  resources :items, controller: "cart_items"

  resources :carts do
    post "checkout",  on: :collection
    delete "clean",   on: :collection
  end

  resources :orders do
    member do
      get :pay_with_credit_card
      post :allpay_notify
    end
  end

  root "products#index"

end
