class ApplicationController < ActionController::Base
  protect_from_forgery

  def rescue_action_in_public(exception)
    case exception
      when ActionController::RoutingError, ActionController::UnknownAction
        render :file => "#{Rails.root}/public/404.html", :status => 404
      else
        render_optional_error_file response_code_for_rescue(exception)
    end
  end

  protected

  EXCEPTIONS_NOT_LOGGED = ['ActionController::UnknownAction', 'ActionController::RoutingError']

  def log_error(exc)
    super unless EXCEPTIONS_NOT_LOGGED.include?(exc.class.name)
  end
end
