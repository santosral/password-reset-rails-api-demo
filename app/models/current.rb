class Current < ActiveSupport::CurrentAttributes
  attribute :user, :session
  attribute :user_agent, :ip_address
end
