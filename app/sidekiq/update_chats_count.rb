class UpdateChatsCount < ActionController::API
    include Sidekiq::Worker

  def perform(*args)
    redis = Redis.new(host: "redis")
    apps = redis.smembers("updated_chat_counts")

    apps.each do |token|
      app = App.find_by(token: token)
      if app
        app.lock!
        chat_number = app.chats_count     
        if redis.exists(token+"#chats_count") || redis.exists(token+"#chats_count") == 1
            chat_number = redis.get(token+"#chats_count").to_i         
        end
        app.chats_count = chat_number
        app.save
        redis.srem("updated_chat_counts",token)
      end
      
    end
  end
end