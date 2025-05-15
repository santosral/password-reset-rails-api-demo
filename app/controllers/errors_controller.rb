class ErrorsController < ActionController::API
  def not_found
    Rails.logger.info "[ActionController::RoutingError] No route matches"
    render json: { errors: "Route not found" }, status: :not_found
  end

  def internal_server_error
    Rails.logger.error "[INTERNAL_SERVER_ERROR] message=#{exception.message}, backtrace=#{exception.backtrace}"
    render json: { errors: "Interal server error" }, status: :internal_server_error
  end
end
