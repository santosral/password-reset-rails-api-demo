class RequestPasswordReset
  def self.call(email_address:)
    Rails.logger.info("[REQUEST_PASSWORD_RESET] Request initiated")

    user = User.find_by(email_address: email_address)
    if user.blank?
      return Result.new(false, nil, [ "User not found" ])
    end

    raw_token = PasswordResetToken.generate_for(
      user,
      ip_address: Current.ip_address,
      user_agent: Current.user_agent,
      expires_at: ActiveSupport::Duration.build(Authentication.config.password_reset_token_expiration).from_now,
      context: :generate
    )

    Rails.logger.info("[REQUEST_PASSWORD_RESET] Token generated for user_id=#{user.id}")

    Result.new(true, raw_token, nil)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.info("[REQUEST_PASSWORD_RESET] Token generation failed, errors=#{e.record.errors.full_messages.join(', ')}")
    Result.new(false, nil, e.record.errors.full_messages)
  end
end
