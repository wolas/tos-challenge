class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  rescue_from StandardError, with: :handle_unexpected_error
  rescue_from ActionController::ParameterMissing, with: :handle_missing_params
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error

  before_action :authenticate

  def handle_missing_params(exception)
    render_error(message: "Missing required parameter: #{exception.param}",
                 status: :bad_request, # HTTP 400
                 code: "missing_parameter")
  end

  def handle_not_found(exception)
    render_error(message: exception.message,
                 status: :not_found, # HTTP 404
                 code: "record_not_found")
  end

  def handle_validation_error(exception)
    render_error(message: exception.record.errors.full_messages.join(", "),
                 status: :unprocessable_entity, # HTTP 422
                 code: "validation_error")
  end

  def handle_unexpected_error(exception)
    Rails.logger.error("Unexpected error: #{exception.message}\n#{exception.backtrace.join("\n")}")

    render_error(message: "An unexpected error occurred",
                 status: :internal_server_error, # HTTP 500
                 code: "unexpected_error")
  end

  def authenticate
    authenticate_with_http_token { |token, _| @current_user = User.find_by(token: token) } || render_unauthorized
  end

  def render_unauthorized(realm = "Application")
    headers["WWW-Authenticate"] = %(Token realm="#{realm.delete('"')}") if realm.is_a?(String)

    render_error(message: "Forbidden access",
                 status: :forbidden, # HTTP 403
                 code: "forbidden")
  end

  def render_error(message:, status:, code:)
    render json: { data: nil, error: { message: message, code: code } }, status: status
  end
end
