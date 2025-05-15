class ApplicationController < ActionController::API
  rescue_from StandardError, with: :handle_internal_server_error
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from ActionView::MissingTemplate, with: :handle_missing_template

  before_action :set_current_attributes

  def handle_routing_error
    Rails.logger.info "[ActionController::RoutingError] No route matches"
    render json: { errors: "Route not found" }, status: :not_found
  end

  private
    def set_current_attributes
      Current.user_agent = request.user_agent
      Current.ip_address = request.remote_ip
    end

    def handle_internal_server_error(exception)
      Rails.logger.error "[#{exception.class}] #{exception.message}, backtrace=#{exception.backtrace}"
      render json: { errors: "Interal server error" }, status: :internal_server_error
    end

    def handle_parameter_missing(exception)
      render json: { errors: "Missing parameters" }, status: :bad_request
    end

    def handle_missing_template(exception)
      Rails.logger.warn "[MissingTemplate] #{exception.message}"
      render json: {
        errors: "Invalid Accept header or missing JSON response"
      }, status: :not_acceptable
    end
end
