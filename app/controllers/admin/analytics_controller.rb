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

  def export
    @start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago.to_date
    @end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.current
    @format = params[:format] || 'pdf'
    
    begin
      # Calculate all analytics data
      @period_stats = calculate_period_stats(@start_date, @end_date)
      @lifetime_stats = calculate_lifetime_stats
      @comparison_stats = calculate_comparison_stats(@start_date, @end_date)
      @product_analytics = calculate_product_analytics(@start_date, @end_date)
      @customer_analytics = calculate_customer_analytics(@start_date, @end_date)
      @contact_analytics = calculate_contact_analytics(@start_date, @end_date)
      
      case @format
      when 'pdf'
        generate_pdf_report
      when 'csv'
        generate_csv_report
      else
        redirect_to admin_analytics_path, alert: 'Invalid export format'
      end
    rescue => e
      Rails.logger.error "Export error: #{e.message}"
      redirect_to admin_analytics_path, alert: "Export failed: #{e.message}"
    end
  end


  private

  def calculate_period_stats(start_date, end_date)
    period_orders = Order.where(:created_at => start_date.beginning_of_day..end_date.end_of_day)
    
    # Initialize daily data with explicit string formatting like dashboard
    revenue_by_day = {}
    orders_by_day = {}
    
    (start_date..end_date).each do |date|
      date_string = date.strftime("%Y-%m-%d")
      revenue_by_day[date_string] = 0
      orders_by_day[date_string] = 0
    end
    
    # Populate with actual data
    period_orders.each do |order|
      order_date = order.created_at.to_date
      date_string = order_date.strftime("%Y-%m-%d")
      if revenue_by_day.key?(date_string)
        revenue_by_day[date_string] += order.total_price
        orders_by_day[date_string] += 1
      end
    end
    
        {
          :revenue => period_orders.sum(:total_price),
          :orders => period_orders.count,
          :average_order_value => period_orders.average(:total_price) || 0,
          :revenue_by_day => revenue_by_day,
          :orders_by_day => orders_by_day,
          :orders_by_status => period_orders.group(:status).count,
          :orders_by_source => period_orders.group(:order_source).count
        }
  end

  def calculate_lifetime_stats
    # Get monthly data with proper year formatting
    revenue_by_month = Order.group_by_month(:created_at, :format => "%b %Y").sum(:total_price)
    orders_by_month = Order.group_by_month(:created_at, :format => "%b %Y").count
    customer_growth = User.group_by_month(:created_at, :format => "%b %Y").count
    
    {
      :total_revenue => Order.sum(:total_price),
      :total_orders => Order.count,
      :total_customers => User.count,
      :total_products => Product.count,
      :average_order_value => Order.average(:total_price) || 0,
      :total_contact_messages => ContactMessage.count,
      :revenue_by_month => revenue_by_month,
      :orders_by_month => orders_by_month,
      :customer_growth => customer_growth
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


  def calculate_percentage_change(old_value, new_value)
    return 0 if old_value == 0
    ((new_value - old_value) / old_value * 100).round(2)
  end

  def generate_pdf_report
    require 'prawn'
    require 'prawn/table'
    
    pdf = Prawn::Document.new(
      page_size: 'A4', 
      page_layout: :portrait,
      margin: [60, 60, 60, 60]
    )
    
    # Define brand colors (matching your website/email design)
    orange_primary = "EA580C"    # #ea580c
    orange_dark = "7E2A0C"      # #7e2a0c  
    orange_light = "FFF7ED"     # #fff7ed
    orange_border = "FED7AA"     # #fed7aa
    text_dark = "292524"        # #292524
    text_light = "374151"       # #374151
    
    # Header with logo and brand styling
    pdf.bounding_box([0, pdf.bounds.height], width: pdf.bounds.width, height: 80) do
      # Company logo (if available)
      begin
        logo_path = Rails.root.join('app', 'assets', 'images', 'Mang-not-text-logo.svg')
        if File.exist?(logo_path)
          pdf.image logo_path, width: 40, height: 40, position: :left
        end
      rescue
        # If logo fails to load, continue without it
      end
      
      # Company name and title
      pdf.bounding_box([50, pdf.bounds.height], width: pdf.bounds.width - 50, height: 80) do
        pdf.fill_color orange_dark
        pdf.text "Mang Crinkle", size: 22, style: :bold, align: :left
        pdf.move_down 4
        
        pdf.fill_color orange_primary
        pdf.text "Sales Analytics Report", size: 16, style: :bold, align: :left
        pdf.move_down 8
        
        pdf.fill_color text_light
        pdf.text "Period: #{@start_date.strftime('%B %d, %Y')} - #{@end_date.strftime('%B %d, %Y')}", size: 11, align: :left
        pdf.text "Generated: #{Time.current.strftime('%B %d, %Y at %I:%M %p')}", size: 9, align: :left
      end
    end
    
    pdf.move_down 20
    
    # Executive Summary Section
    pdf.fill_color orange_dark
    pdf.text "Executive Summary", size: 16, style: :bold
    pdf.move_down 12
    
    # Key metrics in a clean table
    summary_data = [
      ["Metric", "Value", "Metric", "Value"],
      ["Total Revenue", "$#{sprintf('%.2f', @period_stats[:revenue])}", "Total Orders", @period_stats[:orders].to_s],
      ["Average Order Value", "$#{sprintf('%.2f', @period_stats[:average_order_value])}", "Revenue Growth", "#{@comparison_stats[:revenue_change] >= 0 ? '+' : ''}#{@comparison_stats[:revenue_change]}%"]
    ]
    
    pdf.table(summary_data, width: pdf.bounds.width, header: true) do
      row(0).style do |c|
        c.font_style = :bold
        c.background_color = orange_light
        c.text_color = orange_dark
        c.padding = 6
        c.border_color = orange_border
      end
      rows(1..-1).style do |c|
        c.padding = 6
        c.border_color = orange_border
        c.border_width = 0.5
      end
      columns(0).style { |c| c.align = :left }
      columns(1).style { |c| c.align = :left }
      columns(2).style { |c| c.align = :left }
      columns(3).style { |c| c.align = :left }
    end
    
    pdf.move_down 30
    
    # Revenue Analysis Section
    pdf.fill_color orange_dark
    pdf.text "Revenue Analysis", size: 16, style: :bold
    pdf.move_down 12
    
    # Revenue comparison with previous period
    if @comparison_stats[:revenue_change] != 0
      change_color = @comparison_stats[:revenue_change] >= 0 ? "10B981" : "EF4444"
      change_text = @comparison_stats[:revenue_change] >= 0 ? "INCREASE" : "DECREASE"
      
      pdf.fill_color change_color
      pdf.text "Revenue Change: #{change_text} #{@comparison_stats[:revenue_change].abs}% vs Previous Period", size: 12, style: :bold
      pdf.move_down 8
    end
    
    pdf.fill_color text_light
    pdf.text "This analysis shows sales performance for the selected period, including comparison with the previous period.", size: 11
    pdf.move_down 20
    
    # Top Products Section
    pdf.fill_color orange_dark
    pdf.text "Top Performing Products", size: 16, style: :bold
    pdf.move_down 12
    
    if @product_analytics[:top_products].any?
      product_data = [["Rank", "Product Name", "Orders", "Performance"]]
      @product_analytics[:top_products].each_with_index do |(product, count), index|
        performance = index < 3 ? "Top Performer" : "Growing"
        product_data << ["#{index + 1}", product.to_s, count.to_s, performance]
      end
      
      pdf.table(product_data, width: pdf.bounds.width, header: true) do
        row(0).style do |c|
          c.font_style = :bold
          c.background_color = orange_light
          c.text_color = orange_dark
          c.padding = 6
          c.border_color = orange_border
        end
        rows(1..-1).style do |c|
          c.padding = 4
          c.border_color = orange_border
          c.border_width = 0.5
        end
        columns(0).style { |c| c.align = :center }
        columns(1).style { |c| c.align = :left }
        columns(2).style { |c| c.align = :center }
        columns(3).style { |c| c.align = :center }
      end
    else
      pdf.fill_color text_light
      pdf.text "No product data available for this period", style: :italic
    end
    
    pdf.move_down 30
    
    # Customer Analysis Section
    pdf.fill_color orange_dark
    pdf.text "Customer Analysis", size: 16, style: :bold
    pdf.move_down 12
    
    if @customer_analytics[:top_customers].any?
      customer_data = [["Customer", "Orders", "Total Revenue", "Type"]]
      @customer_analytics[:top_customers].each do |customer|
        name = [customer[:first_name], customer[:last_name]].compact.join(' ')
        name = customer[:email] if name.blank?
        customer_type = customer[:order_count] > 1 ? "Returning" : "New"
        customer_data << [name.to_s, customer[:order_count].to_s, "$#{sprintf('%.2f', customer[:total_revenue])}", customer_type]
      end
      
      pdf.table(customer_data, width: pdf.bounds.width, header: true) do
        row(0).style do |c|
          c.font_style = :bold
          c.background_color = orange_light
          c.text_color = orange_dark
          c.padding = 6
          c.border_color = orange_border
        end
        rows(1..-1).style do |c|
          c.padding = 4
          c.border_color = orange_border
          c.border_width = 0.5
        end
        columns(0).style { |c| c.align = :left }
        columns(1).style { |c| c.align = :center }
        columns(2).style { |c| c.align = :center }
        columns(3).style { |c| c.align = :center }
      end
    else
      pdf.fill_color text_light
      pdf.text "No customer data available for this period", style: :italic
    end
    
    pdf.move_down 40
    
    # Footer with branding
    pdf.bounding_box([0, 60], width: pdf.bounds.width, height: 50) do
      pdf.fill_color orange_primary
      pdf.text "Artisanal baked goods made with love and the finest ingredients.", size: 10, align: :center, style: :italic
      pdf.move_down 5
      
      pdf.fill_color text_light
      pdf.text "For questions about this report, contact your business administrator.", size: 9, align: :center
    end
    
    # Page numbers
    pdf.number_pages "Page <page> of <total>", at: [pdf.bounds.right - 50, 20], size: 9
    
    send_data pdf.render, filename: "mang_crinkle_sales_analytics_#{@start_date.strftime('%Y%m%d')}_#{@end_date.strftime('%Y%m%d')}.pdf", type: "application/pdf"
  end

  def generate_csv_report
    require 'csv'
    
    csv_data = CSV.generate do |csv|
      # Header
      csv << ["Analytics Report"]
      csv << ["Period: #{@start_date.strftime('%B %d, %Y')} - #{@end_date.strftime('%B %d, %Y')}"]
      csv << ["Generated: #{Time.current.strftime('%B %d, %Y at %I:%M %p')}"]
      csv << []
      
      # Summary Stats
      csv << ["Summary Statistics"]
      csv << ["Metric", "Value"]
      csv << ["Total Revenue", "$#{sprintf('%.2f', @period_stats[:revenue])}"]
      csv << ["Total Orders", @period_stats[:orders].to_s]
      csv << ["Average Order Value", "$#{sprintf('%.2f', @period_stats[:average_order_value])}"]
      csv << ["Contact Messages", @period_stats[:contact_messages].to_s]
      csv << []
      
      # Top Products
      csv << ["Top Products"]
      csv << ["Product", "Orders"]
      if @product_analytics[:top_products].any?
        @product_analytics[:top_products].each do |product, count|
          csv << [product.to_s, count.to_s]
        end
      else
        csv << ["No product data available for this period"]
      end
      csv << []
      
      # Top Customers
      csv << ["Top Customers"]
      csv << ["Customer", "Orders", "Total Revenue"]
      if @customer_analytics[:top_customers].any?
        @customer_analytics[:top_customers].each do |customer|
          name = [customer[:first_name], customer[:last_name]].compact.join(' ')
          name = customer[:email] if name.blank?
          csv << [name.to_s, customer[:order_count].to_s, "$#{sprintf('%.2f', customer[:total_revenue])}"]
        end
      else
        csv << ["No customer data available for this period"]
      end
    end
    
    send_data csv_data, filename: "analytics_report_#{@start_date.strftime('%Y%m%d')}_#{@end_date.strftime('%Y%m%d')}.csv", type: "text/csv"
  end
end 