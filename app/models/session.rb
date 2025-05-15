class Session < ApplicationRecord
  belongs_to :user

  validates :jti, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where(revoked_at: nil).where("expires_at > ?", Time.current) }

  def revoked?
    revoked_at.present?
  end

  def expired?
    expires_at < Time.current
  end

  def active?
    !revoked? && !expired?
  end

  def revoke!
    update!(revoked_at: Time.current)
  end

  def self.revoke_all_active!
    active.touch_all(:revoked_at)
  end
end
