require "rails_helper"

RSpec.describe RequestPasswordReset do
  describe ".call" do
    let(:user) { create(:user) }

    before do
      allow(Current).to receive(:ip_address).and_return("127.0.0.1")
      allow(Current).to receive(:user_agent).and_return("RSpec")
    end

    context "when user exists" do
      it "returns success and a token" do
        result = described_class.call(email_address: user.email_address)

        expect(result).to be_success
        expect(result.value).to be_present
        expect(result.errors).to be_nil

        expect(user.password_reset_tokens.last).to be_present
      end
    end

    context "when user does not exist" do
      it "returns failure and user not found error" do
        result = described_class.call(email_address: "unknown@example.com")

        expect(result).not_to be_success
        expect(result.value).to be_nil
        expect(result.errors).to include("User not found")
      end
    end

    context "when token creation fails" do
      before do
        allow(PasswordResetToken).to receive(:generate_for)
          .and_raise(ActiveRecord::RecordInvalid.new(PasswordResetToken.new.tap { |t| t.validate }))
      end

      it "returns failure with error messages" do
        result = described_class.call(email_address: user.email_address)

        expect(result).not_to be_success
        expect(result.value).to be_nil
        expect(result.errors).to be_an(Array)
      end
    end
  end
end
