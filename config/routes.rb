require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  Sidekiq::Web.use ActionDispatch::Cookies
  Sidekiq::Web.use ActionDispatch::Session::CookieStore, key: "_interslice_session"
  mount Sidekiq::Web => '/sidekiq'
  namespace :api, defaults: {format: :json}  do
    namespace :v1 do
     post '/applications', to: 'app#create'
     get '/applications', to: 'app#index'
     get '/applications/:app_token', to: 'app#show'
     put '/applications/:app_token', to: 'app#update'
     get '/chats', to: 'chat#index'
     post '/applications/:app_token/chats', to: 'chat#create'
     get '/applications/:app_token/chats', to: 'chat#show'
     get '/messages', to: 'message#index'
     post '/applications/:token/chats/:number/messages', to: 'message#create'
     get '/applications/:token/chats/:number/messages', to: 'message#show'
     post '/applications/:token/chats/:number/messages/search', to: 'message#search'
   end
 end
 match '*unmatched', to: 'application#not_found', via: :all
end
