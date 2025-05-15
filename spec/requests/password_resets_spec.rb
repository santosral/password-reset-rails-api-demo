require 'rails_helper'
require_relative '../support/shared_examples/api_error_responses'

RSpec.describe "PasswordResets", type: :request do
  describe "POST /password_resets" do
    let(:user) { create(:user) }

    context "with valid email" do
      it "returns success and a reset token" do
        post forgot_password_path, params: {
          user: { email_address: user.email_address }
        }, as: :json

        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["reset_url"]).to be_present
      end
    end

    context "with unknown email" do
      it "returns error" do
        post forgot_password_path, params: {
          user: { email_address: "unknown@example.com" }
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]).to include("User not found")
      end
    end

    context "with missing parameters" do
      it_behaves_like "missing parameters error response", :post, forgot_password_path, {}
    end
  end

  describe "PATCH /password_resets/:token" do
    let(:user) { create(:user, password: "OldPassword123") }
    let(:raw_token) {
      PasswordResetToken.generate_for(
        user,
        ip_address: "127.0.0.1",
        user_agent: "RSpec",
        expires_at: 30.minutes.from_now
      )
    }

    context "with valid token and matching passwords" do
      it "resets the password" do
        patch reset_password_path(token: raw_token), params: {
          user: {
            password: "NewPassword123",
            password_confirmation: "NewPassword123"
          }
        }, as: :json

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["token"]).to be_present
      end
    end

    context "with invalid token" do
      it "returns an error" do
        patch reset_password_path(token: 'invalid_token'), params: {
          user: {
            password: "NewPassword123",
            password_confirmation: "NewPassword123"
          }
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]).to include("Invalid or expired token")
      end
    end

    context "with password confirmation mismatch" do
      it "returns an error" do
         patch reset_password_path(token: raw_token), params: {
          user: {
            password: "NewPassword123",
            password_confirmation: "WrongConfirm"
          }
        }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["errors"]).to include("Password confirmation doesn't match Password")
      end
    end

    context "with missing parameters" do
      it_behaves_like "missing parameters error response", :patch, reset_password_path(token: "tttttt"), {}
    end
  end
end
