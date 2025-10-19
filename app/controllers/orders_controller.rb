class OrdersController < ApplicationController
  before_action :set_cart, only: [:new, :create]
  before_action :check_orders_enabled, only: [:new, :create]

  def new
    @order = Order.new
    @cart_items = @cart.cart_items.includes(:product, :crinkle_package)
    
    # Redirect if cart is empty
    if @cart.empty?
      redirect_to products_path, alert: 'Your cart is empty. Please add some items before placing an order.'
      return
    end
    
    # Generate session token to prevent duplicate submissions
    @session_token = SecureRandom.hex(32)
    session[:order_submission_token] = @session_token
  end

  def create
    # Verify reCAPTCHA first with error handling
    begin
      unless verify_recaptcha(action: 'order_form', minimum_score: 0.5)
        @cart_items = @cart.cart_items.includes(:product, :crinkle_package)
        flash.now[:alert] = 'Please complete the reCAPTCHA verification.'
        render :new, status: :unprocessable_entity
        return
      end
    rescue => e
      Rails.logger.error "reCAPTCHA verification failed: #{e.message}"
      @cart_items = @cart.cart_items.includes(:product, :crinkle_package)
      flash.now[:alert] = 'Security verification failed. Please refresh the page and try again.'
      render :new, status: :unprocessable_entity
      return
    end
    
    # Check for duplicate submission using session-based token
    session_token = params[:order][:session_token]
    if session_token.blank? || session[:order_submission_token] != session_token
      @cart_items = @cart.cart_items.includes(:product, :crinkle_package)
      flash.now[:alert] = 'Invalid form submission. Please try again.'
      render :new, status: :unprocessable_entity
      return
    end
    
    # Clear the token to prevent reuse
    session[:order_submission_token] = nil
    
    @order = Order.new(order_params)
    @cart_items = @cart.cart_items.includes(:product, :crinkle_package)
    
    # Handle customer creation/linking
    if customer_params[:email].present?
      customer_service = CustomerService.new(
        customer_params[:email],
        customer_params.except(:email)
      )
      @order.user = customer_service.find_or_create_customer
    end
    
    # Use database transaction to ensure atomicity
    ActiveRecord::Base.transaction do
      if @order.save
        # Convert cart items to line items
        @cart_items.each do |cart_item|
          if cart_item.product.present?
            # Handle individual products
            @order.line_items.create!(
              purchasable: cart_item.product,
              quantity: cart_item.quantity,
              price: cart_item.product.price
            )
          elsif cart_item.crinkle_package.present?
            # Handle packages with selected products
            @order.line_items.create!(
              purchasable: cart_item.crinkle_package,
              quantity: cart_item.quantity,
              price: cart_item.crinkle_package.price,
              product_quantities: cart_item.product_quantities
            )
          end
        end
        
        # Recalculate total after all line items are created
        @order.calculate_total
        @order.save!
        
        # Clear the cart after successful order
        @cart.cart_items.destroy_all
        session[:cart_id] = nil
        
        # Send emails after successful order creation
        # Use perform_later with a small delay to ensure order is fully saved
        OrderConfirmationJob.set(wait: 1.second).perform_later(@order.id)
        
        # Send notification to admins who have new order notifications enabled
        User.admins.find_each do |admin|
          prefs = admin.notification_preferences
          if prefs.new_order_notifications?
            AdminNotificationJob.set(wait: 1.second).perform_later(@order.id, admin.id)
          end
        end
        
        redirect_to order_path(@order), notice: 'Thank you for your order!'
      else
        render :new, status: :unprocessable_entity
      end
    end
  rescue => e
    Rails.logger.error "Order creation failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    @cart_items = @cart.cart_items.includes(:product, :crinkle_package)
    flash.now[:alert] = 'There was an error processing your order. Please try again.'
    render :new, status: :unprocessable_entity
  end

  def show
    @order = Order.find(params[:id])
  end

  private

  def check_orders_enabled
    unless Rails.application.config.orders_enabled
      redirect_to cart_path, alert: Rails.application.config.orders_disabled_reason
    end
  end

  def set_cart
    @cart = current_cart
  end

  def order_params
    params.require(:order).permit(
      :customer_name,
      :email,
      :phone,
      :address,
      :session_token
    )
  end

  def customer_params
    params.require(:order).permit(
      :email,
      :first_name,
      :last_name,
      :phone,
      :address,
      :newsletter_subscribed
    )
  end
end
