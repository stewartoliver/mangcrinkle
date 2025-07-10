class OrdersController < ApplicationController
  before_action :set_cart, only: [:new, :create]

  def new
    @order = Order.new
    @cart_items = @cart.cart_items.includes(:product, :crinkle_package)
    
    # Redirect if cart is empty
    if @cart.empty?
      redirect_to products_path, alert: 'Your cart is empty. Please add some items before placing an order.'
      return
    end
  end

  def create
    # Verify reCAPTCHA first
    unless verify_recaptcha_if_needed
      @cart_items = @cart.cart_items.includes(:product, :crinkle_package)
      flash.now[:alert] = 'Please complete the reCAPTCHA verification.'
      render :new, status: :unprocessable_entity
      return
    end
    
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
      
      # Send order confirmation email to customer
      puts "🍪 DEBUG: Sending order confirmation email to: #{@order.email}"
      CustomerMailer.order_confirmation(@order).deliver_now
      puts "✅ DEBUG: Customer email sent successfully"
      
      # Send notification to admins who have new order notifications enabled
      admin_users = User.admins
      
      puts "🍪 DEBUG: Found #{admin_users.count} total admin users"
      
      admin_users.find_each do |admin|
        # Ensure admin has notification preferences (creates with defaults if missing)
        prefs = admin.notification_preferences
        puts "🍪 DEBUG: Admin #{admin.email} - new_order_notifications: #{prefs.new_order_notifications}"
        
        if prefs.new_order_notifications?
          puts "🍪 DEBUG: Sending admin notification to: #{admin.email}"
          AdminMailer.new_order_notification(@order, admin).deliver_now
          puts "✅ DEBUG: Admin email sent successfully to #{admin.email}"
        else
          puts "⚠️  DEBUG: Admin #{admin.email} has notifications disabled"
        end
      end
      
      # Clear the cart after successful order
      @cart.cart_items.destroy_all
      session[:cart_id] = nil
      
      redirect_to order_path(@order), notice: 'Thank you for your order!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  private

  def set_cart
    @cart = current_cart
  end

  def order_params
    params.require(:order).permit(
      :customer_name,
      :email,
      :phone,
      :address
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
