module Api
    module V1
        class MessageController < ApplicationController
            def index
                messages = Message.order('created_at DESC')
                render json: {data:messages}.to_json(:except => [:id, :chat_id, :created_at, :updated_at]),status: :ok
            end

            def create
                if message_params[:body].nil? || message_params[:body].empty?
                    return render json: { error: "Invalid Message Body" }, status: :unprocessable_entity
                end
                chat = Chat.find_by(app_token: params[:token], number: params[:number])
                if chat.nil?
                    return render json: {data:"No Chat Found"},status:  :not_found
                end

                redis = Redis.new(host: "redis")
                message = Message.new(message_params)
                message.number = chat.messages_count + 1

                # Automically get and update the messages count to handle race condition
                if redis.exists(chat.id.to_s+"#messages_count") || redis.exists(chat.id.to_s+"#messages_count") == 1
                    message.number = redis.incr(chat.id.to_s+"#messages_count")
                    redis.set(message.chat_id.to_s+"#messages_count",message.number) 
                    redis.sadd("updated_messages_counts",chat.id)      
                end

                message.chat_id = chat.id  
                MessagesCreatorJob.perform_async(message.to_json)
                return render json: {data:message}.to_json(:except => [:id, :chat_id, :created_at, :updated_at]), status: :ok
            end
            
            def search
                chat = Chat.find_by(app_token: params[:token], number: params[:number])
                if chat.nil?
                    return render json: {data:"No Chat Found"},status:  :not_found
                end 

                # Handling ES index not created exception 
                if Message.count == 0
                    return render json: {data:[]},status:  :ok
                end

                messages = Message.search(params[:query])
                if messages
                    filtered_messages = messages.where(chat_id: chat.id)
                    if filtered_messages
                        return render json: {data:filtered_messages}.to_json(:except => [:id, :chat_id, :created_at, :updated_at]), status: :ok
                    end
                end
            end


            def show
                chat = Chat.find_by(app_token: params[:token], number: params[:number])
                if chat
                    messages = Message.where(chat_id: chat.id)
                    messages ||= []
                    return render json: {data:messages}.to_json(:except => [:id, :chat_id, :created_at, :updated_at]),status: :ok
                else
                    return render json: {data:"No Chat Found"},status:  :not_found
                end
            end
            
            private
            def message_params
                params.require(:message).permit(:body)
            end
        end  
    end
end