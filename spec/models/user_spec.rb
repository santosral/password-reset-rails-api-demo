require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:user) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is invalid without email_address" do
      subject.email_address = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:email_address]).to include("can't be blank")
    end

    it "normalizes email_address to lowercase" do
      subject.email_address = "UPPER@EXAMPLE.COM "
      subject.valid?
      expect(subject.email_address).to eq("upper@example.com")
    end

    it "is invalid with short password" do
      subject.password = "short"
      subject.password_confirmation = "short"
      expect(subject).not_to be_valid
      expect(subject.errors[:password]).to include("is too short (minimum is 8 characters)")
    end

    it "validates presence of password_confirmation only on :reset_password context" do
      subject.password_confirmation = nil
      expect(subject.valid?).to eq(true)

      expect(subject.valid?(:reset_password)).to eq(false)
      expect(subject.errors[:password_confirmation]).to include("can't be blank")
    end
  end

  describe "#reset_password!" do
    before { subject.save! }

    it "successfully resets password with confirmation" do
      create(:session, user: subject, expires_at: 1.day.from_now, revoked_at: nil)
      expect {
        subject.reset_password!(new_password: "newsecurepassword", new_password_confirmation: "newsecurepassword")
      }.to change { subject.reload.password_digest }
        .and change { subject.sessions.active.count }

      expect(subject.errors).to be_empty
    end

    it "raises error when password_confirmation does not match in reset_password context" do
      expect {
        subject.reset_password!(new_password: "newpass123", new_password_confirmation: "wrongconfirmation")
      }.to raise_error(ActiveRecord::RecordInvalid) do |error|
        expect(error.record.errors[:password_confirmation]).to include("doesn't match Password")
      end
    end

    it "revokes all active sessions after password reset" do
      session = subject.sessions.create!(jti: SecureRandom.uuid, expires_at: 1.hour.from_now)
      expect(session.revoked?).to be false

      subject.reset_password!(new_password: "newsecurepass", new_password_confirmation: "newsecurepass")

      expect(session.reload.revoked?).to be true
    end
  end
end
