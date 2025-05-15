class PasswordResetToken < ApplicationRecord
  belongs_to :user

  with_options on: :generate do
    validates :token_digest, presence: true, uniqueness: true
    validates :expires_at, presence: true, comparison: { greater_than: Time.current }
  end

  scope :active, -> { where(used_at: nil).where(revoked_at: nil).where("expires_at > ?", Time.current) }

  def expired?
    expires_at < Time.current
  end

  def used?
    used_at.present?
  end

  def revoked?
    revoked_at.present?
  end

  def active?
    !expired? && !used? && !revoked?
  end

  def mark_used!
    update!(used_at: Time.current)
  end

  def self.digest(token)
    Digest::SHA256.hexdigest(token)
  end

  def self.generate_for(user, ip_address:, user_agent:, expires_at:, context: :generate)
    raw_token = SecureRandom.hex(32)
    transaction do
      user.password_reset_tokens.active.touch_all(:revoked_at)
      token = new(
        user: user,
        token_digest: digest(raw_token),
        expires_at: expires_at,
        ip_address: ip_address,
        user_agent: user_agent
      )
      token.save!(context: context)
    end
    raw_token
  end

  def self.find_by_token(raw_token)
    digest = digest(raw_token)
    find_by(token_digest: digest)
  end
end
