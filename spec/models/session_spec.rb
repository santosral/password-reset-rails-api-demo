require "rails_helper"

RSpec.describe Session, type: :model do
  subject { create(:session, jti: "abc123", expires_at: 1.day.from_now, revoked_at: nil) }

  let(:user) { create(:user) }

  describe "validations" do
    it "is valid with valid attributes" do
      session = Session.new(user: user, jti: "token123", expires_at: 1.day.from_now)
      expect(session).to be_valid
    end

    it "is invalid without a jti" do
      session = Session.new(user: user, jti: nil, expires_at: 1.day.from_now)
      expect(session).not_to be_valid
    end

    it "is invalid without an expires_at" do
      session = Session.new(user: user, jti: "token123", expires_at: nil)
      expect(session).not_to be_valid
    end

    it "enforces uniqueness of jti" do
      Session.create!(user: user, jti: "unique123", expires_at: 1.day.from_now)
      duplicate = Session.new(user: user, jti: "unique123", expires_at: 1.day.from_now)
      expect(duplicate).not_to be_valid
    end
  end

  describe "scopes" do
    it "returns only active sessions" do
      active = Session.create!(user: user, jti: "active", expires_at: 1.day.from_now)
      expired = Session.create!(user: user, jti: "expired", expires_at: 1.day.ago)
      revoked = Session.create!(user: user, jti: "revoked", expires_at: 1.day.from_now, revoked_at: Time.current)

      expect(Session.active).to include(active)
      expect(Session.active).not_to include(expired, revoked)
    end
  end

  it "#revoked? returns true if revoked_at is set" do
    subject.update!(revoked_at: Time.current)
    expect(subject.revoked?).to be true
  end

  it "#expired? returns true if expires_at is in the past" do
    subject.update!(expires_at: 1.day.ago)
    expect(subject.expired?).to be true
  end

  it "#active? returns true only if not revoked and not expired" do
    expect(subject.active?).to be true

    subject.update!(revoked_at: Time.current)
    expect(subject.active?).to be false

    subject.update!(revoked_at: nil, expires_at: 1.day.ago)
    expect(subject.active?).to be false
  end

  it "#revoke! sets revoked_at" do
    expect { subject.revoke! }.to change { subject.reload.revoked_at }.from(nil)
  end


  describe ".revoke_all_active!" do
    it "revokes all active sessions" do
      active1 = Session.create!(user: user, jti: "1", expires_at: 1.day.from_now)
      active2 = Session.create!(user: user, jti: "2", expires_at: 2.days.from_now)
      expired = Session.create!(user: user, jti: "3", expires_at: 1.day.ago)

      Session.revoke_all_active!
      expect(active1.reload.revoked_at).not_to be_nil
      expect(active2.reload.revoked_at).not_to be_nil
      expect(expired.reload.revoked_at).to be_nil
    end
  end
end
