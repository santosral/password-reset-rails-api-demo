class ChangePassword
  def self.call(raw_token:, new_password:, new_password_confirmation:)
    Rails.logger.info("[CHANGE_PASSWORD] Password reset attempt")

    password_reset_record = PasswordResetToken.active.find_by_token(raw_token)
    if password_reset_record.blank?
      return Result.new(false, nil, [ "Invalid or expired token" ])
    end

    user = password_reset_record.user

    session = nil
    token = nil

    User.transaction do
      user.reset_password!(new_password: new_password, new_password_confirmation: new_password_confirmation)
      password_reset_record.mark_used!

      token_expiration = ActiveSupport::Duration.build(Authentication.config.access_token_expiration).from_now
      session = user.sessions.create!(
        jti: SecureRandom.uuid,
        expires_at: token_expiration,
        user_agent: Current.user_agent,
        ip_address: Current.ip_address
      )
      token = AccessToken.encode(
        sub: user.id,
        jti: session.jti,
        exp: token_expiration.to_i,
        key: Rails.application.credentials.jwt_secret_key
      )
    end

    Rails.logger.info("[CHANGE_PASSWORD] Password reset successful for user_id=#{user.id}, session_id=#{session.id}")

    Result.new(true, token, nil)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.info("[CHANGE_PASSWORD] Validation failed for user_id=#{user&.id}, errors=#{e.record.errors.full_messages.join(', ')}")
    Result.new(false, nil, e.record.errors.full_messages)
  rescue StandardError => e
    Rails.logger.error("[CHANGE_PASSWORD] Unexpected error for user_id=#{user&.id}, " \
      "error=#{e.class} message=#{e.message}, backtrace=#{e.backtrace}")
    Result.new(false, nil, [ "#{e.class}: #{e.message}" ])
  end
end
