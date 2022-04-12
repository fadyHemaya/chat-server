module Api
    module V1
        class ChatController < ApplicationController
            def index
                chats = Chat.order('created_at DESC')
                render json: {data:chats}.to_json(:except => [:id, :created_at, :updated_at]),status: :ok         
            end

            def create
                app = App.find_by(token: params[:app_token])
                if app
                    redis = Redis.new(host: "redis")
                    chat = Chat.new(app_token: params[:app_token])
                    chat.messages_count = 0

                    # Automically get and update the chats count to handle race condition
                    chat.number = redis.incr(app.token+"#chats_count")
                    
                    # To be updated by Sidekiq CRON job
                    redis.sadd("updated_chat_counts",chat.app_token)

                    ChatsCreatorJob.perform_async(chat.to_json)
                    return render json: {data:chat}.to_json(:except => [:id, :created_at, :updated_at]),status: :ok
                else
                    return render json: {data:"No App Found"},status:  :not_found
                end
            end

            def show
                application = App.find_by(token: params[:app_token])
                if application
                    chats = Chat.where(app_token: params[:app_token])
                    chats ||= []
                    return render json: {data: chats}.to_json(:except => [:id, :created_at, :updated_at]),status: :ok
                else
                    return render json: {data:"No App Found"},status:  :not_found
                end
            end
        end
    end
end
