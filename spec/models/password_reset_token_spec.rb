require 'rails_helper'

RSpec.describe PasswordResetToken, type: :model do
  let(:user) { create(:user) }

  describe 'validations' do
    it 'is valid with required attributes' do
      token = PasswordResetToken.new(
        user: user,
        token_digest: 'abc123',
        expires_at: 30.minutes.from_now
      )
      expect(token).to be_valid
    end

    it 'is invalid without token_digest' do
      token = PasswordResetToken.new(user: user, expires_at: 30.minutes.from_now, token_digest: nil)
      expect(token.valid?(:generate)).to be(false)
    end

    it 'is invalid when token_digest is not unique' do
      token_1 = create(:password_reset_token)
      token = PasswordResetToken.new(
        user: user,
        token_digest: token_1.token_digest,
        expires_at: 30.minutes.from_now
      )
      expect(token.valid?(:generate)).to be(false)
    end


    it 'is invalid without expires_at' do
      token = PasswordResetToken.new(user: user, token_digest: 'abc123')
      expect(token.valid?(:generate)).to be(false)
    end

    it 'is invalid if expires_at is less than current Time' do
      token = PasswordResetToken.new(user: user, token_digest: 'abc123', expires_at: 1.minute.ago)
      expect(token.valid?(:generate)).to be(false)
    end
  end

  describe '.active' do
    it 'returns only active tokens' do
      active = create(:password_reset_token, user: user, expires_at: 1.hour.from_now, used_at: nil, revoked_at: nil)
      create(:password_reset_token, user: user, expires_at: 1.hour.ago, used_at: nil, revoked_at: nil)
      create(:password_reset_token, user: user, expires_at: 1.hour.from_now, used_at: Time.current, revoked_at: nil)
      create(:password_reset_token, user: user, expires_at: 1.hour.from_now, used_at: nil, revoked_at: Time.current)

      expect(PasswordResetToken.active).to contain_exactly(active)
    end
  end

  describe '#expired?' do
    it 'returns true if expires_at is in the past' do
      token = build(:password_reset_token, expires_at: 1.minute.ago)
      expect(token.expired?).to be true
    end

    it 'returns false if expires_at is in the future' do
      token = build(:password_reset_token, expires_at: 1.minute.from_now)
      expect(token.expired?).to be false
    end
  end

  describe '#used?' do
    it 'returns true if used_at is set' do
      token = build(:password_reset_token, used_at: Time.current)
      expect(token.used?).to be true
    end

    it 'returns false if used_at is nil' do
      token = build(:password_reset_token, used_at: nil)
      expect(token.used?).to be false
    end
  end

  describe '#revoked?' do
    it 'returns true if revoked_at is set' do
      token = build(:password_reset_token, revoked_at: Time.current)
      expect(token.revoked?).to be true
    end

    it 'returns false if revoked_at is nil' do
      token = build(:password_reset_token, revoked_at: nil)
      expect(token.revoked?).to be false
    end
  end

  describe '#active?' do
    it 'is true if not expired, used, or revoked' do
      token = build(:password_reset_token, expires_at: 1.hour.from_now, used_at: nil, revoked_at: nil)
      expect(token.active?).to be true
    end

    it 'is false if expired' do
      token = build(:password_reset_token, expires_at: 1.minute.ago)
      expect(token.active?).to be false
    end

    it 'is false if used' do
      token = build(:password_reset_token, used_at: Time.current)
      expect(token.active?).to be false
    end

    it 'is false if revoked' do
      token = build(:password_reset_token, revoked_at: Time.current)
      expect(token.active?).to be false
    end
  end

  describe '#mark_used!' do
    it 'sets used_at to current time' do
      token = create(:password_reset_token, used_at: nil)
      freeze_time do
        token.mark_used!
        expect(token.used_at).to eq(Time.current)
      end
    end
  end

  describe '.digest' do
    it 'returns SHA256 digest of token' do
      raw = 'sometoken'
      expected = Digest::SHA256.hexdigest(raw)
      expect(PasswordResetToken.digest(raw)).to eq(expected)
    end
  end

  describe '.generate_for' do
    it 'revokes previous active tokens and creates new one' do
      old = create(:password_reset_token, user: user, expires_at: 1.hour.from_now)
      token = PasswordResetToken.generate_for(
        user,
        ip_address: '127.0.0.1',
        user_agent: 'RSpec',
        expires_at: 2.hours.from_now
      )

      expect(user.password_reset_tokens.count).to eq(2)
      expect(old.reload.revoked_at).not_to be_nil
      expect(token).to be_a(String)
    end
  end

  describe '.find_by_token' do
    it 'finds token by raw value' do
      raw = 'supersecuretoken'
      digest = PasswordResetToken.digest(raw)
      token = create(:password_reset_token, user: user, token_digest: digest)
      expect(PasswordResetToken.find_by_token(raw)).to eq(token)
    end
  end
end
