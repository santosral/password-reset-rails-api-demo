require 'rails_helper'

RSpec.describe ChangePassword do
  describe '.call' do
    let(:user) { create(:user) }
    let(:token) { "validtoken123" }
    let(:password_reset_token) do
      create(:password_reset_token,
             raw_token: token,
             user: user,
             used_at: nil,
             expires_at: 1.hour.from_now)
    end
    let(:new_password) { "new_password_123" }
    let(:new_password_confirmation) { "new_password_123" }

    before do
      allow(Current).to receive(:user_agent).and_return("RSpec Test Agent")
      allow(Current).to receive(:ip_address).and_return("127.0.0.1")
    end

    context 'when token is invalid or expired' do
      subject(:result) { described_class.call(raw_token: "badtoken", new_password: new_password, new_password_confirmation: new_password_confirmation) }

      before do
        allow(PasswordResetToken.active).to receive(:find_by_token).with("badtoken").and_return(nil)
      end

      it 'returns failure result' do
        expect(result.success?).to be false
        expect(result.errors).to include("Invalid or expired token")
        expect(result.value).to be_nil
      end
    end

    context 'when token is valid and passwords match' do
      subject(:result) { described_class.call(raw_token: token, new_password: new_password, new_password_confirmation: new_password_confirmation) }

      before do
        allow(PasswordResetToken).to receive_message_chain(:active, :find_by_token)
          .with(token)
          .and_return(password_reset_token)

        expect(user).to receive(:reset_password!).with(
          new_password: new_password,
          new_password_confirmation: new_password_confirmation
        ).and_call_original
        expect(password_reset_token).to receive(:mark_used!).and_call_original
      end

      it 'returns a successful result with token' do
        expect(result.success?).to be true
        expect(result.value).to be_a(String)
        expect(result.errors).to be_nil
      end

      it 'marks the password reset token as used' do
        result
        expect(password_reset_token.reload.used_at).not_to be_nil
      end

      it 'creates a session for the user' do
        result
        expect(user.sessions.count).to be > 0
      end
    end

    context 'when password reset fails validation' do
      subject(:result) { described_class.call(raw_token: token, new_password: new_password, new_password_confirmation: "mismatch") }

      before do
        allow(PasswordResetToken).to receive_message_chain(:active, :find_by_token)
          .with(token)
          .and_return(password_reset_token)

        allow(user).to receive(:reset_password!).and_raise(ActiveRecord::RecordInvalid.new(user))
        allow(user).to receive_message_chain(:errors, :full_messages).and_return([ "Password confirmation doesn't match Password" ])
      end

      it 'returns failure with validation errors' do
        expect(result.success?).to be false
        expect(result.errors).to include("Password confirmation doesn't match Password")
        expect(result.value).to be_nil
      end
    end

    context 'when an unexpected error occurs' do
      subject(:result) { described_class.call(raw_token: token, new_password: new_password, new_password_confirmation: new_password_confirmation) }

      before do
        allow(PasswordResetToken).to receive_message_chain(:active, :find_by_token)
          .with(token)
          .and_return(password_reset_token)

        allow(user).to receive(:reset_password!).and_raise(StandardError.new("something bad happened"))
      end

      it 'returns failure with error message' do
        expect(result.success?).to be false
        expect(result.errors.first).to match(/StandardError: something bad happened/)
        expect(result.value).to be_nil
      end
    end
  end
end
