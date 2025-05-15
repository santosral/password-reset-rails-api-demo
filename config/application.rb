require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AuthService
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Singapore"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Store a reference to the encryption key in the encrypted message itself.
    # This is useful if you're rotating encryption keys or supporting multiple keys.
    # When enabled, Rails can later identify which key to use for decryption.
    config.active_record.encryption.store_key_references = true

    # Setup structured logging
    config.semantic_logger.application = "auth_service"
    config.semantic_logger.environment = Rails.env
    config.rails_semantic_logger.started    = true
    config.rails_semantic_logger.processing = true
    config.rails_semantic_logger.rendered   = true
    config.log_tags = {
      request_id:      :request_id,
      ip:              :remote_ip,
      request_url:     :original_url,
      request_method:  :request_method,
      user_agent:      :user_agent
    }
    # # For testing JSON format
    # config.semantic_logger.add_appender(io: $stdout, formatter: :json)

    # Route exceptions like 404 and 500 to custom controller actions
    # This allows Rails to handle errors via the router
    config.exceptions_app = self.routes

  # Set the default host for URL helpers (e.g., reset_password_url)
  Rails.application.routes.default_url_options[:host] = ENV.fetch("APP_HOST", "")
  end
end
