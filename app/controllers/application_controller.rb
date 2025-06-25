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
end
