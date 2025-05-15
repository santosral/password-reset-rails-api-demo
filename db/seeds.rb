# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Seeding data..."

ActiveRecord::Base.transaction do
  users = FactoryBot.create_list(:user, 10)
  puts "Created dummy #{users.count} users"

  users.each do |user|
    FactoryBot.create_list(:session, rand(1..3), user: user)
    FactoryBot.create_list(:password_reset_token, rand(1..3), user: user)
  end
  puts "Created sessions and password reset tokens for dummy users"

  test_user = FactoryBot.create(:user, email_address: "shondra_reilly@lemke.example", password: "p5h8^vo&N")
  puts "Created Test User: email_address=shondra_reilly@lemke.example password=p5h8^vo&N"

  test_user_sessions = FactoryBot.create_list(
    :session, 2,
    user: test_user,
    expires_at: Faker::Time.forward(days: 1),
    revoked_at: nil
  )
  test_user_sessions.each_with_index do |test_user_session, i|
    i += 1
    puts "Created Session ##{i}: expired?=#{test_user_session.expired?} revoked?=#{test_user_session.revoked?} active=#{test_user_session.active?}"
  end

  FactoryBot.create(
    :password_reset_token,
    user: test_user,
    expires_at: 30.minutes.from_now,
    revoked_at: nil,
    used_at: nil,
  )
  puts "Created Expired Reset Password Token"

  FactoryBot.create(
    :password_reset_token,
    user: test_user,
    expires_at: 30.minutes.from_now,
    revoked_at: Time.current,
    used_at: nil,
  )
  puts "Created Revoked Reset Password Token"

  FactoryBot.create(
    :password_reset_token,
    user: test_user,
    expires_at: 30.minutes.from_now,
    revoked_at: nil,
    used_at: nil,
  )
  puts "Created Valid Reset Password Token"
end

puts "Seeding complete."
