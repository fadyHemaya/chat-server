class Chat < ApplicationRecord
  belongs_to :app, :foreign_key => 'app_token', :class_name => 'App', :primary_key => 'token'
  before_save :default_value
  def default_value
    self.messages_count ||= 0
  end
end
