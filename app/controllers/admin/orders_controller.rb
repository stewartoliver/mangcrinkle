class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :set_orders, only: [:index]

  def index
    @orders = apply_filters(@orders)
    @orders = @orders.page(params[:page]).per(25)
    
    # Statistics for the current filtered results
    @total_orders = @orders.total_count
    @total_revenue = @orders.sum(&:total_price)
    @orders_by_status = @orders.group_by(&:status)
  end

  def new
    @order = Order.new
    @products = Product.active
    @crinkle_packages = CrinklePackage.active.ordered_by_quantity
  end

  def create
    Rails.logger.info "=== ADMIN ORDER CREATE ==="
    Rails.logger.info "All params keys: #{params.keys}"
    Rails.logger.info "Line items params: #{params[:line_items].inspect}"
    Rails.logger.info "Order params: #{order_params.inspect}"
    
    @order = Order.new(order_params)
    @products = Product.active
    @crinkle_packages = CrinklePackage.active.ordered_by_quantity
    
    # Handle customer creation/linking
    if order_params[:email].present?
      customer_name_parts = order_params[:customer_name]&.split(' ') || []
      customer_service = CustomerService.new(
        order_params[:email],
        {
          first_name: customer_name_parts.first,
          last_name: customer_name_parts[1..-1]&.join(' '),
          phone: order_params[:phone],
          address: order_params[:address]
        }
      )
      @order.user = customer_service.find_or_create_customer
    end
    
    # Set order source based on the form
    @order.order_source = order_params[:order_source] || 'admin_phone'
    
    if @order.save
      # Add line items if provided
      if params[:line_items].present?
        params[:line_items].each_with_index do |item_params, index|
          next if item_params[:quantity].blank? || item_params[:quantity].to_i <= 0
          
          if item_params[:product_id].present?
            product = Product.find(item_params[:product_id])
            @order.line_items.create!(
              purchasable: product,
              quantity: item_params[:quantity].to_i,
              price: product.price
            )
          elsif item_params[:package_id].present?
            package = CrinklePackage.find(item_params[:package_id])
            
            # Parse product_quantities if it's a JSON string
            product_quantities = {}
            if item_params[:product_quantities].present?
              if item_params[:product_quantities].is_a?(String)
                begin
                  product_quantities = JSON.parse(item_params[:product_quantities])
                rescue JSON::ParserError => e
                  Rails.logger.error "Failed to parse product_quantities JSON: #{e.message}"
                  product_quantities = {}
                end
              else
                product_quantities = item_params[:product_quantities]
              end
            end
            
            @order.line_items.create!(
              purchasable: package,
              quantity: item_params[:quantity].to_i,
              price: package.price,
              product_quantities: product_quantities
            )
          end
        end
        
        # Recalculate total after all line items are created
        @order.calculate_total
        @order.save!
      end
      
      # Add a note about the order creation
      @order.add_note("Order created by admin (#{@order.order_source_display})", current_user)
      
      redirect_to admin_order_path(@order), notice: 'Order was successfully created.'
    else
      # Set instance variables for the view
      @products = Product.active
      @crinkle_packages = CrinklePackage.active.ordered_by_quantity
      
      # Add flash message with errors
      flash.now[:alert] = "Order creation failed: #{@order.errors.full_messages.join(', ')}"
      
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @order_notes = @order.order_notes.recent
  end

  def edit
    @products = Product.active
    @crinkle_packages = CrinklePackage.active.ordered_by_quantity
  end

  def update
    Rails.logger.debug "=== UPDATE ORDER START ===" if Rails.env.development?
    Rails.logger.debug "Request method: #{request.method}" if Rails.env.development?
    Rails.logger.debug "Request path: #{request.path}" if Rails.env.development?
    Rails.logger.debug "All params: #{params.inspect}" if Rails.env.development?
    Rails.logger.debug "Order params: #{order_params.inspect}" if Rails.env.development?
    Rails.logger.debug "Line items params: #{params[:line_items].inspect}" if Rails.env.development?
    Rails.logger.debug "Removed line item IDs: #{params[:removed_line_item_ids].inspect}" if Rails.env.development?
    Rails.logger.debug "Updated line items: #{params[:updated_line_item_ids].inspect}" if Rails.env.development?
    
    if @order.update(order_params)
      Rails.logger.debug "Order updated successfully" if Rails.env.development?
      
      # Handle removed line items
      if params[:removed_line_item_ids].present?
        Rails.logger.debug "Removing line items: #{params[:removed_line_item_ids]}" if Rails.env.development?
        params[:removed_line_item_ids].each do |line_item_id|
          line_item = @order.line_items.find_by(id: line_item_id)
          if line_item
            line_item.destroy
            Rails.logger.debug "Removed line item: #{line_item_id}" if Rails.env.development?
          else
            Rails.logger.debug "Line item not found: #{line_item_id}" if Rails.env.development?
          end
        end
      end
      
      # Handle updated line items
      if params[:updated_line_item_ids].present?
        Rails.logger.debug "Updating line items: #{params[:updated_line_item_ids]}" if Rails.env.development?
        params[:updated_line_item_ids].each do |line_item_id|
          line_item = @order.line_items.find_by(id: line_item_id)
          if line_item && params["updated_line_item_quantities_#{line_item_id}"].present?
            product_quantities = JSON.parse(params["updated_line_item_quantities_#{line_item_id}"])
            line_item.update(product_quantities: product_quantities)
            Rails.logger.debug "Updated line item: #{line_item_id}" if Rails.env.development?
          end
        end
      end
      
      # Handle new line items
      if params[:line_items].present?
        Rails.logger.debug "Adding new line items: #{params[:line_items].length}" if Rails.env.development?
        params[:line_items].each_with_index do |item_params, index|
          Rails.logger.debug "Processing line item #{index + 1}: #{item_params.inspect}" if Rails.env.development?
          next if item_params[:quantity].blank? || item_params[:quantity].to_i <= 0
          
          if item_params[:product_id].present?
            product = Product.find(item_params[:product_id])
            @order.line_items.create!(
              purchasable: product,
              quantity: item_params[:quantity].to_i,
              price: product.price
            )
            Rails.logger.debug "Added product line item: #{product.name}" if Rails.env.development?
          elsif item_params[:package_id].present?
            package = CrinklePackage.find(item_params[:package_id])
            
            # Parse product_quantities if it's a JSON string
            product_quantities = {}
            if item_params[:product_quantities].present?
              if item_params[:product_quantities].is_a?(String)
                begin
                  product_quantities = JSON.parse(item_params[:product_quantities])
                rescue JSON::ParserError => e
                  Rails.logger.error "Failed to parse product_quantities JSON: #{e.message}"
                  product_quantities = {}
                end
              else
                product_quantities = item_params[:product_quantities]
              end
            end
            
            @order.line_items.create!(
              purchasable: package,
              quantity: item_params[:quantity].to_i,
              price: package.price,
              product_quantities: product_quantities
            )
            Rails.logger.debug "Added package line item: #{package.name}" if Rails.env.development?
          end
        end
        
        # Recalculate total after all line items are created
        @order.calculate_total
        @order.save!
        Rails.logger.debug "Recalculated total: #{@order.total_price}" if Rails.env.development?
      end
      
      Rails.logger.debug "=== UPDATE ORDER SUCCESS ===" if Rails.env.development?
      redirect_to admin_order_path(@order), notice: 'Order was successfully updated.'
    else
      Rails.logger.debug "=== UPDATE ORDER FAILED ===" if Rails.env.development?
      Rails.logger.debug "Errors: #{@order.errors.full_messages}" if Rails.env.development?
      @products = Product.active
      @crinkle_packages = CrinklePackage.active.ordered_by_quantity
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @order.destroy
    
    respond_to do |format|
      format.html { redirect_to admin_orders_path, notice: 'Order was successfully deleted.' }
      format.json { render json: { success: true, message: 'Order was successfully deleted.' } }
    end
  end

  def bulk_update
    order_ids = params[:order_ids]
    new_status = params[:new_status]
    
    if order_ids.present? && new_status.present?
      orders = Order.where(id: order_ids)
      updated_count = 0
      
      orders.each do |order|
        if order.update(status: new_status)
          order.add_note("Bulk status update to #{new_status.titleize}", current_user)
          updated_count += 1
        end
      end
      
      redirect_to admin_orders_path, notice: "Successfully updated #{updated_count} orders to #{new_status.titleize}."
    else
      redirect_to admin_orders_path, alert: 'Please select orders and a new status.'
    end
  end

  def export
    @orders = apply_filters(Order.all)
    
    respond_to do |format|
      format.csv do
        send_data generate_csv(@orders), filename: "orders-#{Date.current}.csv"
      end
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def set_orders
    @orders = Order.includes(:user, :line_items).order(created_at: :desc)
  end

  def apply_filters(orders)
    # Status filter
    orders = orders.by_status(params[:status]) if params[:status].present?
    
    # Order source filter
    orders = orders.by_order_source(params[:order_source]) if params[:order_source].present?
    
    # Date range filter
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
      orders = orders.by_date_range(start_date, end_date)
    end
    
    # Customer name search
    orders = orders.by_customer(params[:customer_name]) if params[:customer_name].present?
    
    # Email search - exact match by default, partial if specified
    if params[:email].present?
      if params[:email_search_type] == 'partial'
        orders = orders.by_email_partial(params[:email])
      else
        # Default to exact match
        orders = orders.by_email(params[:email])
      end
    end
    
    # Order ID search
    orders = orders.by_order_id(params[:order_id]) if params[:order_id].present?
    
    # Total price range
    orders = orders.by_min_total(params[:min_total]) if params[:min_total].present?
    orders = orders.by_max_total(params[:max_total]) if params[:max_total].present?
    
    orders
  end

  def order_params
    params.require(:order).permit(
      :status, :customer_name, :email, :phone, :address,
      :tracking_number, :shipping_carrier, :estimated_delivery, :shipped_at, :delivered_at,
      :order_source
    )
  end

  def generate_csv(orders)
    require 'csv'
    
    CSV.generate(headers: true) do |csv|
      csv << ['Order ID', 'Customer', 'Email', 'Phone', 'Status', 'Total', 'Date', 'Items']
      
      orders.each do |order|
        items = order.line_items.map { |item| "#{item.quantity}x #{item.name}" }.join(', ')
        csv << [
          order.id,
          order.customer_name,
          order.email,
          order.phone,
          order.status,
          order.total_price,
          order.created_at.strftime('%Y-%m-%d %H:%M'),
          items
        ]
      end
    end
  end
end
