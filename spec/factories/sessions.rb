FactoryBot.define do
  factory :session do
    association :user
    jti { SecureRandom.uuid }
    ip_address { Faker::Internet.public_ip_v4_address }
    user_agent { Faker::Internet.user_agent }
    expires_at { 1.day.from_now }
    revoked_at do
      if rand(0..1).zero?
        Faker::Time.backward(days: 2)
      else
        Faker::Time.forward(days: 2)
      end
    end
  end
end
