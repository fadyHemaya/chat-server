Rails.application.routes.draw do
  namespace :api, defaults: {format: :json}  do
    namespace :v1 do
     post '/app', to: 'app#create'
     get '/app', to: 'app#index'
   end
 end
end
