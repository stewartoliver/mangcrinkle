class Admin::AnalyticsController < Admin::BaseController
  def index
    # Date ranges
    @start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago.to_date
    @end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.current
    
    # Revenue analytics
    @total_revenue = Order.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day).sum(:total_price)
    @revenue_by_day = Order.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                           .group_by_day(:created_at, format: "%b %d, %Y")
                           .sum(:total_price)
    
    # Order analytics
    @total_orders = Order.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day).count
    @orders_by_day = Order.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                         .group_by_day(:created_at, format: "%b %d, %Y")
                         .count
    
    # Order status breakdown
    @orders_by_status = Order.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                            .group(:status)
                            .count
    
    # Top products - simplified to avoid polymorphic issues
    @top_products = LineItem.joins(:order)
                           .where(orders: { created_at: @start_date.beginning_of_day..@end_date.end_of_day })
                           .where(purchasable_type: 'Product')
                           .joins("INNER JOIN products ON line_items.purchasable_id = products.id")
                           .group('products.name')
                           .order('COUNT(line_items.id) DESC')
                           .limit(10)
                           .count('line_items.id')
    
    # Top customers
    @top_customers = Order.joins(:user)
                         .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                         .group('users.email')
                         .order('COUNT(orders.id) DESC')
                         .limit(10)
                         .count
    
    # Average order value
    @average_order_value = Order.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                               .average(:total_price) || 0
    
    # Revenue by month (for trend analysis)
    @revenue_by_month = Order.where(created_at: 12.months.ago.beginning_of_day..@end_date.end_of_day)
                            .group_by_month(:created_at, format: "%b %Y")
                            .sum(:total_price)
    
    # Orders by source
    @orders_by_source = Order.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                            .group(:order_source)
                            .count
    
    # Contact messages analytics
    @total_messages = ContactMessage.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day).count
    @messages_by_status = ContactMessage.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                                      .group(:status)
                                      .count
    
    # Response time analytics (if available)
    if ContactMessage.column_names.include?('responded_at')
      @avg_response_time = ContactMessage.where.not(responded_at: nil)
                                       .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                                       .average('EXTRACT(EPOCH FROM (responded_at - created_at)) / 3600') || 0
    end
    
    # Previous period comparison
    period_length = (@end_date - @start_date).to_i
    @previous_start_date = @start_date - period_length.days
    @previous_end_date = @start_date - 1.day
    
    @previous_revenue = Order.where(created_at: @previous_start_date.beginning_of_day..@previous_end_date.end_of_day).sum(:total_price)
    @previous_orders = Order.where(created_at: @previous_start_date.beginning_of_day..@previous_end_date.end_of_day).count
    
    @revenue_change = @previous_revenue > 0 ? ((@total_revenue - @previous_revenue) / @previous_revenue * 100).round(2) : 0
    @orders_change = @previous_orders > 0 ? ((@total_orders - @previous_orders) / @previous_orders * 100).round(2) : 0
  end
end 