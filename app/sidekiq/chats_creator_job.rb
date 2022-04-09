class ChatsCreatorJob
  include Sidekiq::Job
  QUEUE = 'chats-creator'
  
  sidekiq_options queue: QUEUE, retry: true

  def perform(args)
      redis = Redis.new(host: "redis")
      chat_params = JSON.parse(args).symbolize_keys
      chat = Chat.new(chat_params)
      chat.save
      redis.set(chat.id.to_s+"#messages_count",0)
  end
end
