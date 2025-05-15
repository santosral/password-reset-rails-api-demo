class ApplicationController < ActionController::API
  rescue_from StandardError, with: :handle_internal_server_error
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

  private
    # Add any data here that we want to log and is not accessible from request object.
    def append_info_to_payload(payload)
      super
      user_id = Current.user&.id
      payload[:user_id] = user_id if user_id.present?
    end

    def handle_internal_server_error(exception)
      logger.error "#{exception.class}: #{exception.message}"
      render "shared/error_response", locals: {
        status: "error",
        message: "Interal server error",
        errors: [ "#{exception.class}: #{exception.message} #{exception.backtrace}" ]
      } and return
    end

    def handle_parameter_missing(exception)
      render "shared/error_response", locals: {
        status: "error",
        message: "Invalid parameters",
        errors: []
      }, status: :bad_request and return
    end
end
