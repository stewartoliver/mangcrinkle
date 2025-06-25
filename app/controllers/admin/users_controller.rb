class Admin::UsersController < Admin::BaseController
  def index
    @users = User.all.order(created_at: :desc)
    @customers = User.customers.order(created_at: :desc)
    @admins = User.admins.order(created_at: :desc)
    @newsletter_subscribers = User.newsletter_subscribers.order(created_at: :desc)
  end

  def show
    @user = User.find(params[:id])
    
    if @user.customer?
      # Get orders directly associated with the user
      @user_orders = @user.orders.order(created_at: :desc)
      
      # Get orders by contact details (email, phone) that might not be directly associated
      @orders_by_email = Order.where(email: @user.email).where.not(user: @user).order(created_at: :desc)
      @orders_by_phone = Order.where(phone: @user.phone).where.not(user: @user).order(created_at: :desc)
      
      # Combine all orders for statistics
      @all_orders = (@user_orders + @orders_by_email + @orders_by_phone).uniq.sort_by(&:created_at).reverse
      
      # Calculate statistics
      @total_orders = @all_orders.count
      @total_spent = @all_orders.sum(&:total_price)
      @average_order_value = @total_orders > 0 ? @total_spent / @total_orders : 0
      @orders_by_status = @all_orders.group_by(&:status)
      @recent_orders = @all_orders.first(5)
      
      # Monthly spending for the last 12 months
      @monthly_spending = {}
      12.times do |i|
        month_start = i.months.ago.beginning_of_month
        month_end = i.months.ago.end_of_month
        month_orders = @all_orders.select { |order| order.created_at.between?(month_start, month_end) }
        @monthly_spending[month_start.strftime("%B %Y")] = month_orders.sum(&:total_price)
      end
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      redirect_to admin_user_path(@user), notice: 'User created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def search
    email = params[:email]&.downcase&.strip
    customer = User.customers.find_by(email: email)
    
    if customer
      render json: {
        customer: {
          id: customer.id,
          email: customer.email,
          full_name: customer.full_name,
          phone: customer.phone,
          address: customer.address
        }
      }
    else
      render json: { customer: nil }
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'User updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    # Only allow contact details and user type changes, not password changes
    params.require(:user).permit(
      :email, :user_type, :first_name, :last_name,
      :phone, :address, :newsletter_subscribed
    )
  end
end 