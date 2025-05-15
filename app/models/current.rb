class Current < ActiveSupport::CurrentAttributes
  attribute :user, :session
  attribute :user_agent, :remote_ip
end
