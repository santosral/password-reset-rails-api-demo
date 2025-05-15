require "authentication"

Authentication.configure do |config|
  config.password_reset_token_expiration = ENV.fetch("PASSWORD_RESET_TOKEN_EXPIRATION", "1800").to_i
  config.access_token_expiration = ENV.fetch("ACCESS_TOKEN_DURATION", "86400").to_i
end
