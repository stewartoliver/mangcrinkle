class Admin::AnalyticsController < Admin::BaseController
  def index
    # Date ranges
    @start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago.to_date
    @end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.current
    
    # Preset date ranges
    @preset_ranges = {
      'last_7_days' => {:start => 7.days.ago.to_date, :end_date => Date.current, :label => 'Last 7 Days'},
      'last_30_days' => {:start => 30.days.ago.to_date, :end_date => Date.current, :label => 'Last 30 Days'},
      'last_90_days' => {:start => 90.days.ago.to_date, :end_date => Date.current, :label => 'Last 90 Days'},
      'this_month' => {:start => Date.current.beginning_of_month, :end_date => Date.current, :label => 'This Month'},
      'last_month' => {:start => 1.month.ago.beginning_of_month, :end_date => 1.month.ago.end_of_month, :label => 'Last Month'},
      'this_year' => {:start => Date.current.beginning_of_year, :end_date => Date.current, :label => 'This Year'},
      'last_year' => {:start => 1.year.ago.beginning_of_year, :end_date => 1.year.ago.end_of_year, :label => 'Last Year'}
    }
    
    # Period-specific analytics (affected by date range)
    @period_stats = calculate_period_stats(@start_date, @end_date)
    
    # Lifetime stats (not affected by date range)
    @lifetime_stats = calculate_lifetime_stats
    
    # Previous period comparison
    @comparison_stats = calculate_comparison_stats(@start_date, @end_date)
    
    # Additional analytics
    @product_analytics = calculate_product_analytics(@start_date, @end_date)
    @customer_analytics = calculate_customer_analytics(@start_date, @end_date)
    @contact_analytics = calculate_contact_analytics(@start_date, @end_date)
  end

  private

  def calculate_period_stats(start_date, end_date)
    period_orders = Order.where(:created_at => start_date.beginning_of_day..end_date.end_of_day)
    
    {
      :revenue => period_orders.sum(:total_price),
      :orders => period_orders.count,
      :average_order_value => period_orders.average(:total_price) || 0,
      :revenue_by_day => period_orders.group_by_day(:created_at, :format => "%b %d").sum(:total_price),
      :orders_by_day => period_orders.group_by_day(:created_at, :format => "%b %d").count,
      :orders_by_status => period_orders.group(:status).count,
      :orders_by_source => period_orders.group(:order_source).count,
      :contact_messages => ContactMessage.where(:created_at => start_date.beginning_of_day..end_date.end_of_day).count,
      :messages_by_status => ContactMessage.where(:created_at => start_date.beginning_of_day..end_date.end_of_day)
                                     .group(:status).count
    }
  end

  def calculate_lifetime_stats
    {
      :total_revenue => Order.sum(:total_price),
      :total_orders => Order.count,
      :total_customers => User.count,
      :total_products => Product.count,
      :average_order_value => Order.average(:total_price) || 0,
      :total_contact_messages => ContactMessage.count,
      :revenue_by_month => Order.group_by_month(:created_at, :format => "%b %Y").sum(:total_price),
      :orders_by_month => Order.group_by_month(:created_at, :format => "%b %Y").count,
      :customer_growth => User.group_by_month(:created_at, :format => "%b %Y").count
    }
  end

  def calculate_comparison_stats(start_date, end_date)
    period_length = (end_date - start_date).to_i
    previous_start = start_date - period_length.days
    previous_end = start_date - 1.day
    
    previous_orders = Order.where(:created_at => previous_start.beginning_of_day..previous_end.end_of_day)
    current_orders = Order.where(:created_at => start_date.beginning_of_day..end_date.end_of_day)
    
    previous_revenue = previous_orders.sum(:total_price)
    current_revenue = current_orders.sum(:total_price)
    previous_count = previous_orders.count
    current_count = current_orders.count
    
    {
      :revenue_change => previous_revenue > 0 ? ((current_revenue - previous_revenue) / previous_revenue * 100).round(2) : 0,
      :orders_change => previous_count > 0 ? ((current_count - previous_count) / previous_count * 100).round(2) : 0,
      :previous_revenue => previous_revenue,
      :previous_orders => previous_count
    }
  end

  def calculate_product_analytics(start_date, end_date)
    period_line_items = LineItem.joins(:order)
                               .where(:orders => { :created_at => start_date.beginning_of_day..end_date.end_of_day })
                               .where(:purchasable_type => 'Product')
    
    {
      :top_products => period_line_items.joins("INNER JOIN products ON line_items.purchasable_id = products.id")
                                    .group('products.name')
                                    .order('COUNT(line_items.id) DESC')
                                    .limit(10)
                                    .count('line_items.id'),
      :total_products_sold => period_line_items.count,
      :unique_products_sold => period_line_items.distinct.count('purchasable_id')
    }
  end

  def calculate_customer_analytics(start_date, end_date)
    period_orders = Order.where(:created_at => start_date.beginning_of_day..end_date.end_of_day)
    
    # Get top customers with more detailed information
    top_customers_data = period_orders.joins(:user)
                                     .group('users.id, users.email, users.first_name, users.last_name')
                                     .order('COUNT(orders.id) DESC')
                                     .limit(10)
                                     .pluck('users.id, users.email, users.first_name, users.last_name, COUNT(orders.id), SUM(orders.total_price)')
    
    top_customers = top_customers_data.map do |user_id, email, first_name, last_name, order_count, total_revenue|
      {
        id: user_id,
        email: email,
        first_name: first_name,
        last_name: last_name,
        order_count: order_count,
        total_revenue: total_revenue || 0
      }
    end
    
    {
      :top_customers => top_customers,
      :new_customers => User.where(:created_at => start_date.beginning_of_day..end_date.end_of_day).count,
      :returning_customers => period_orders.joins(:user)
                                      .group('users.id')
                                      .having('COUNT(orders.id) > 1')
                                      .count.count
    }
  end

  def calculate_contact_analytics(start_date, end_date)
    period_messages = ContactMessage.where(:created_at => start_date.beginning_of_day..end_date.end_of_day)
    
    analytics = {
      :total_messages => period_messages.count,
      :messages_by_status => period_messages.group(:status).count
    }
    
    # Response time analytics (if available)
    if ContactMessage.column_names.include?('responded_at')
      analytics[:avg_response_time] = ContactMessage.where.not(:responded_at => nil)
                                                  .where(:created_at => start_date.beginning_of_day..end_date.end_of_day)
                                                  .average('EXTRACT(EPOCH FROM (responded_at - created_at)) / 3600') || 0
    end
    
    analytics
  end
end 