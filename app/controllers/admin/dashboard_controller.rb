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
    
    # Orders by day (last 7 days)
    @orders_by_day = Order.where(created_at: 7.days.ago..Time.current)
                         .group("DATE(created_at)")
                         .count
    
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
