class ErrorsController < ApplicationController
  def not_found
    @error_code = '404'
    @error_title = 'Page Not Found'
    @error_message = "The page you're looking for doesn't exist."
    render_error_page
  end

  def unprocessable_entity
    @error_code = '422'
    @error_title = 'Invalid Request'
    @error_message = 'The request was well-formed but contained invalid data.'
    render_error_page(status: :unprocessable_entity)
  end

  def internal_server_error
    @error_code = '500'
    @error_title = 'Internal Server Error'
    @error_message = 'We encountered an unexpected error. Please try again.'
    render_error_page(status: :internal_server_error)
  end

  # Test actions for development - these will let you preview the error pages
  def test_404
    @error_code = '404'
    @error_title = 'Page Not Found'
    @error_message = "The page you're looking for doesn't exist."
    render_error_page
  end

  def test_500
    @error_code = '500'
    @error_title = 'Internal Server Error'
    @error_message = 'We encountered an unexpected error. Please try again.'
    
    # Create a fake exception for testing admin error details
    if admin_user?
      @exception = StandardError.new("This is a test exception to demonstrate admin error details")
      @exception.set_backtrace([
        "app/controllers/test_controller.rb:42:in `test_method'",
        "app/controllers/application_controller.rb:15:in `handle_error'",
        "actionpack (7.0.0) lib/action_controller/metal/rescue.rb:23:in `rescue_with_handler'"
      ])
    end
    
    render_error_page(status: :internal_server_error)
  end

  private

  def render_error_page(status: :not_found)
    # Use centralized admin detection
    @is_admin = admin_user?
    
    # Log the decision for debugging
    Rails.logger.info "Error page decision: user_signed_in=#{user_signed_in?}, current_user=#{current_user&.id}, admin=#{current_user&.admin?}, activated=#{current_user&.activated?}, is_admin=#{@is_admin}"
    
    if @is_admin
      render 'admin_error', layout: 'admin', status: status
    else
      render 'customer_error', layout: 'application', status: status
    end
  end
end 