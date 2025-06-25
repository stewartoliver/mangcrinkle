class ApplicationController < ActionController::Base
  helper_method :current_cart

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

  # Devise helper methods
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def sign_in(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def sign_out(user)
    session[:user_id] = nil
    @current_user = nil
  end

  def user_signed_in?
    current_user.present?
  end
end
