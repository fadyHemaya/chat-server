class App < ApplicationRecord
  has_secure_token
  before_save :default_value
  def default_value
    self.chats_count ||= 0
  end
end
