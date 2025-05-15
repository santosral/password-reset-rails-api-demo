FactoryBot.define do
  factory :password_reset_token do
    association :user

    expires_at { ActiveSupport::Duration.build(Authentication.config.password_reset_token_expiration).from_now }
    used_at do
      if rand(0..1).zero?
        Faker::Time.backward(days: 2)
      else
        Faker::Time.forward(days: 2)
      end
    end
    revoked_at do
      if rand(0..1).zero?
        Faker::Time.backward(days: 2)
      else
        Faker::Time.forward(days: 2)
      end
    end
    user_agent { Faker::Internet.user_agent }
    ip_address { Faker::Internet.public_ip_v4_address }

    transient do
      raw_token { SecureRandom.hex(32) }
    end

    token_digest { Digest::SHA256.hexdigest(raw_token) }
  end
end
