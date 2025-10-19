class Admin::UsersController < Admin::BaseController
  def index
    # Base query with includes for performance
    @users = User.includes(:orders).order(created_at: :desc)
    
    # Calculate stats for ALL users (before any filtering)
    @total_customers = @users.where(user_type: 'customer').count
    @total_admins = @users.where(user_type: 'admin').count
    @pending_activation = User.pending_activation.count
    @total_newsletter_subscribers = User.newsletter_subscribers.count
    
    # Store current tab for view
    @current_tab = params[:tab] || 'all'
    
    # Apply filters (including tab filtering) AFTER calculating counts
    @users = apply_filters(@users)
    
    # Get the filtered count BEFORE pagination
    @filtered_users_count = @users.count
    
    # Apply pagination after filtering
    @users = @users.page(params[:page]).per(25)
  end

  def show
    @user = User.find(params[:id])
    
    if @user.customer?
      # Get orders directly associated with the user
      @user_orders = @user.orders.order(created_at: :desc)
      
      # Get orders by contact details (email, phone) that might not be directly associated
      # Use exact email matching (case-insensitive) to ensure we only get orders for this specific email
      @orders_by_email = Order.where("LOWER(email) = LOWER(?)", @user.email)
                             .where.not(user: @user)
                             .order(created_at: :desc)
      @orders_by_phone = Order.where(phone: @user.phone).where.not(user: @user).order(created_at: :desc)
      
      # Combine all orders for statistics
      @all_orders = (@user_orders + @orders_by_email + @orders_by_phone).uniq.sort_by(&:created_at).reverse
      
      # Calculate statistics
      @total_orders = @all_orders.count
      @total_spent = @all_orders.sum(&:total_price)
      @average_order_value = @total_orders > 0 ? @total_spent / @total_orders : 0
      @orders_by_status = @all_orders.group_by(&:status)
      @recent_orders = @all_orders.first(5)
      
      # Monthly spending for the last 12 months - optimized with database queries
      @monthly_spending = {}
      12.times do |i|
        month_start = i.months.ago.beginning_of_month
        month_end = i.months.ago.end_of_month
        
        # Query orders by email and phone for this month
        month_orders_by_email = Order.where("LOWER(email) = LOWER(?)", @user.email)
                                   .where(created_at: month_start..month_end)
                                   .where.not(user: @user)
        month_orders_by_phone = Order.where(phone: @user.phone)
                                   .where(created_at: month_start..month_end)
                                   .where.not(user: @user)
        month_user_orders = @user_orders.where(created_at: month_start..month_end)
        
        # Sum all orders for this month
        total_spent = month_user_orders.sum(:total_price) + 
                     month_orders_by_email.sum(:total_price) + 
                     month_orders_by_phone.sum(:total_price)
        
        @monthly_spending[month_start.strftime("%B %Y")] = total_spent
      end
      
      # Get contact messages for this user
      @contact_messages = @user.contact_messages.recent.limit(10)
      @total_contact_messages = @user.contact_messages.count
      @contact_messages_by_status = @user.contact_messages.group_by(&:status)
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      redirect_to admin_user_path(@user), notice: 'Customer created successfully.'
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
    
    # Check if user type is changing from customer to admin
    changing_to_admin = @user.customer? && user_params[:user_type] == 'admin'
    
    if @user.update(user_params)
      if changing_to_admin
        redirect_to admin_user_path(@user), notice: 'User updated successfully and changed to admin. Use the "Send Activation Email" button to allow them to set up their password.'
      else
        redirect_to admin_user_path(@user), notice: 'User updated successfully.'
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def activate
    @user = User.find(params[:id])
    
    unless @user.admin?
      redirect_to admin_user_path(@user), alert: 'Only admin users can be activated.'
      return
    end

    if @user.activated?
      redirect_to admin_user_path(@user), alert: 'Admin user is already activated.'
      return
    end

    # Send activation email using background job
    AdminActivationJob.perform_later(@user.id)
    
    redirect_to admin_user_path(@user), notice: 'Activation email sent successfully! The admin will receive an email with instructions to set up their password.'
  end

  def reset_password
    @user = User.find(params[:id])
    
    unless @user.admin?
      redirect_to admin_user_path(@user), alert: 'Only admin users can have their passwords reset.'
      return
    end

    unless @user.activated?
      redirect_to admin_user_path(@user), alert: 'Admin user must be activated before password reset.'
      return
    end

    # Send password reset email using background job
    AdminPasswordResetJob.perform_later(@user.id)
    
    redirect_to admin_user_path(@user), notice: 'Password reset email sent successfully! The admin will receive an email with instructions to reset their password.'
  end

  private

  def apply_filters(users)
    # Filter by user type (from form) or tab parameter
    user_type_filter = params[:user_type] || params[:tab]
    if user_type_filter.present? && user_type_filter != 'all'
      users = users.where(user_type: user_type_filter)
    end
    
    # Filter by admin status
    if params[:admin_status].present?
      case params[:admin_status]
      when 'activated'
        users = users.where(user_type: 'admin').where.not(activated_at: nil)
      when 'pending'
        users = users.where(user_type: 'admin', activated_at: nil)
      end
    end
    
    # Filter by newsletter subscription
    if params[:newsletter_subscribed].present?
      users = users.where(newsletter_subscribed: params[:newsletter_subscribed] == 'true')
    end
    
    # Search by name or email
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      users = users.where(
        "LOWER(first_name) LIKE LOWER(?) OR LOWER(last_name) LIKE LOWER(?) OR LOWER(email) LIKE LOWER(?)",
        search_term, search_term, search_term
      )
    end
    
    # Filter by date range
    if params[:start_date].present?
      users = users.where("created_at >= ?", Date.parse(params[:start_date]).beginning_of_day)
    end
    
    if params[:end_date].present?
      users = users.where("created_at <= ?", Date.parse(params[:end_date]).end_of_day)
    end
    
    users
  end

  def user_params
    # Allow password parameters for user creation, but not for updates
    if action_name == 'create'
      params.require(:user).permit(
        :email, :user_type, :first_name, :last_name,
        :phone, :address, :newsletter_subscribed,
        :password, :password_confirmation
      )
    else
      # Only allow contact details and user type changes for updates, not password changes
      params.require(:user).permit(
        :email, :user_type, :first_name, :last_name,
        :phone, :address, :newsletter_subscribed
      )
    end
  end
end 