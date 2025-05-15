class User < ApplicationRecord
  has_secure_password

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  has_many :sessions, dependent: :destroy
  has_many :password_reset_tokens, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true, format: URI::MailTo::EMAIL_REGEXP
  validates :password, presence: true, length: { minimum: 8 }

  validates :password_confirmation, presence: true, on: :reset_password

  def reset_password!(new_password:, new_password_confirmation:)
    transaction do
      self.password = new_password
      self.password_confirmation = new_password_confirmation
      save!(context: :reset_password)
      sessions.revoke_all_active!
    end
  end
end
