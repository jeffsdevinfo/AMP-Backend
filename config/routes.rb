Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create]
      post '/login', to: 'auth#create'
      post '/admin_create_lease', to: 'users#admin_create_lease'
      post '/admin_create_property', to: 'users#admin_create_property'
      post '/admin_create_payment', to: 'users#admin_create_payment'
      post '/renter_create_payment', to: 'users#renter_create_payment'
      post '/admin_get_payment_history_for_renter', to: 'users#admin_get_payment_history_for_renter'
      post '/admin_charge_monthly_rents_active_leases', to: 'users#admin_charge_monthly_rents_active_leases'
      post '/comment_subset', to: 'users#comment_subset'
      post '/create_comment', to: 'users#create_comment'

      get '/users/:id', to: 'users#show'      

      get '/profile', to: 'users#profile'
      get '/profile_detail', to: 'users#profile_detail'
      get '/renter_get_lease', to: 'users#renter_get_lease'
      get '/renter_get_payment_history', to: 'users#renter_get_payment_history'
      get '/admin_get_all_users', to: 'users#admin_get_all_users'
      get '/admin_get_all_lease_types', to: 'users#admin_get_all_lease_types'
      get '/admin_get_all_leases', to: 'users#admin_get_all_leases'
      get '/admin_get_all_properties', to: 'users#admin_get_all_properties'
      get '/admin_get_all_payments', to: 'users#admin_get_all_payments'
      get '/admin_get_all_active_leases', to: 'users#admin_get_all_active_leases'
      get '/admin_get_all_terminated_leases', to: 'users#admin_get_all_terminated_leases'
      

      patch '/update_profile', to: 'users#update_profile'
      patch '/admin_update_profile', to: 'users#admin_update_profile'
      patch '/admin_terminate_lease', to: 'users#admin_terminate_lease'
      patch '/admin_apply_payment_to_lease', to: 'users#admin_apply_payment_to_lease'                      
      patch '/admin_manually_apply_monthly_rent_to_active_leases', to: 'users#admin_manually_apply_monthly_rent_to_active_leases'

      resources :property_addresses, only: [:create, :show]
        #get '/users/:id', to: 'users#show'   
        #get '/property_addresses/:id', to: 'property_addresses#show'
        patch '/update_property_address', to: 'property_addresses#update_property_address'
    end
  end
end
