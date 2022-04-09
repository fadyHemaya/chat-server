class MessagesCreatorJob
  include Sidekiq::Job
  QUEUE = 'messages-creator'
  
  sidekiq_options queue: QUEUE, retry: true
  def perform(args)
    message_params = JSON.parse(args).symbolize_keys
    message = Message.new(message_params)                  
    message.save
  end
end
