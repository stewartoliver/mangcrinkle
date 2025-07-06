class Admin::DashboardController < Admin::BaseController
  def index
    @recent_orders = Order.order(created_at: :desc, id: :desc).limit(5)
    @total_orders = Order.count
    @total_products = Product.count
    @total_revenue = Order.sum(:total_price)
    
    # Order status breakdown
    @orders_by_status = Order.group(:status).count
    
    # Recent revenue (last 7 days)
    @recent_revenue = Order.where(created_at: 7.days.ago..Time.current).sum(:total_price)
    
    # Contact Messages Statistics
    @total_contact_messages = ContactMessage.count
    @new_contact_messages = ContactMessage.where(status: 'new').count
    @urgent_contact_messages = ContactMessage.where(priority: 'urgent').count
    @recent_contact_messages = ContactMessage.includes(:user)
                                            .where.not(status: ['resolved', 'cancelled'])
                                            .recent
                                            .limit(5)
    
    # For navigation badge
    @new_contact_messages_count = @new_contact_messages
    
    # Orders by day - Simplified approach to avoid conversion errors
    week_start = Date.current.beginning_of_week
    week_end = week_start + 6.days
    
    # Initialize the hash with all days of the week set to 0 using string keys
    @orders_by_day = {}
    (0..6).each do |i|
      date = week_start + i.days
      date_string = date.strftime("%Y-%m-%d")  # Explicit string formatting
      @orders_by_day[date_string] = 0
    end
    
    # Get actual order counts from database
    orders_this_week = Order.where(created_at: week_start.beginning_of_day..week_end.end_of_day)
    
    # Count orders by date
    orders_this_week.each do |order|
      order_date = order.created_at.to_date
      date_string = order_date.strftime("%Y-%m-%d")  # Explicit string formatting
      if @orders_by_day.key?(date_string)
        @orders_by_day[date_string] += 1
      end
    end
    
    # Also calculate for better dashboard stats
    @this_week_orders = @orders_by_day.values.sum
    @last_week_orders = Order.where(
      created_at: (week_start - 7.days).beginning_of_day..(week_start - 1.day).end_of_day
    ).count
    
    # Top customers
    @top_customers = Order.joins(:user)
                         .group('users.email')
                         .order('COUNT(orders.id) DESC')
                         .limit(5)
                         .count
    
    # Pending orders count
    @pending_orders = Order.where(status: 'pending').count
    @processing_orders = Order.where(status: 'processing').count
  end
end
