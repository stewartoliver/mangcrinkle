class ApplicationController < ActionController::Base
  helper_method :current_cart

  # Add error handling for custom error pages
  rescue_from StandardError, with: :handle_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActionController::RoutingError, with: :handle_not_found

  private

  def current_cart
    @current_cart ||= begin
      if session[:cart_id]
        Cart.find_by(id: session[:cart_id]) || create_cart
      else
        create_cart
      end
    end
  end

  def create_cart
    cart = Cart.create!
    session[:cart_id] = cart.id
    cart
  end

  # Custom user session methods (renamed to avoid Devise conflicts)
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def custom_sign_in(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def custom_sign_out(user)
    session[:user_id] = nil
    @current_user = nil
  end

  def user_signed_in?
    current_user.present?
  end

  # Error handling methods
  def handle_not_found
    @error_code = '404'
    @error_title = 'Page Not Found'
    @error_message = "The page you're looking for doesn't exist."
    render_error_page
  end

  def handle_error(exception)
    @error_code = '500'
    @error_title = 'Something Went Wrong'
    @error_message = 'We encountered an unexpected error. Please try again.'
    @exception = exception if user_signed_in? && current_user.admin?
    
    Rails.logger.error "Error #{exception.class}: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    
    render_error_page(status: :internal_server_error)
  end

  def render_error_page(status: :not_found)
    @is_admin = user_signed_in? && current_user.admin?
    
    if @is_admin
      render 'errors/admin_error', layout: 'admin', status: status
    else
      render 'errors/customer_error', layout: 'application', status: status
    end
  end
end
