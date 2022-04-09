class UpdateMessagesCount < ActionController::API
    include Sidekiq::Worker

  def perform(*args)
    redis = Redis.new(host: "redis")
    chats = redis.smembers("updated_messages_counts")

    chats.each do |id|
      chat = Chat.find(id.to_i)
      if chat
        chat.lock!
        message_number = chat.messages_count     
        if redis.exists(id+"#messages_count") || redis.exists(id+"#messages_count") == 1
          message_number = redis.get(id+"#messages_count").to_i         
        end
        chat.messages_count = message_number
        chat.save
        redis.srem("updated_messages_counts",id)
      end     
    end
  end
end