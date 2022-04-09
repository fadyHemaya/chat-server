sidekiq_config = { url: 'redis://redis:6379/0' }

Sidekiq.configure_server do |config|
    ActiveRecord::Base.establish_connection(
      :adapter  => "mysql2",
      :host     => ENV['DB_HOST'],
      :username => ENV['DB_USER'],
      :password => ENV['DB_PASSWORD'],
      :database => ENV['DB_NAME'],
    )
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end

schedule_file = "config/schedule.yml"
if File.exist?(schedule_file) && Sidekiq.server?
   Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end