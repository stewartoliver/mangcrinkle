class AdminMailer < ApplicationMailer
  def new_order_notification(order, admin_user)
    @order = order
    @admin_user = admin_user
    @customer_name = @order.user&.display_name || @order.customer_name
    
    mail(
      to: @admin_user.email,
      subject: "New Order ##{@order.id} - #{@customer_name} - $#{@order.total_price}"
    )
  end

  def new_contact_message(contact_message, admin_user)
    @contact_message = contact_message
    @admin_user = admin_user
    @customer = @contact_message.user
    
    mail(
      to: @admin_user.email,
      subject: "New Contact Message: #{@contact_message.subject}"
    )
  end

  def weekly_sales_report(admin_user, report_data)
    @admin_user = admin_user
    @report_data = report_data
    @week_start = report_data[:week_start]
    @week_end = report_data[:week_end]
    
    mail(
      to: @admin_user.email,
      subject: "Weekly Sales Report - #{@week_start.strftime('%b %d')} to #{@week_end.strftime('%b %d, %Y')}"
    )
  end

  def monthly_sales_report(admin_user, report_data)
    @admin_user = admin_user
    @report_data = report_data
    @month = report_data[:month]
    @year = report_data[:year]
    
    mail(
      to: @admin_user.email,
      subject: "Monthly Sales Report - #{Date::MONTHNAMES[@month]} #{@year}"
    )
  end

  def template_preview(admin_user, template, variables = {})
    @admin_user = admin_user
    @template = template
    @variables = variables
    
    rendered = @template.render_with_variables(@variables)
    @subject = rendered[:subject]
    @body = rendered[:body]
    
    mail(
      to: @admin_user.email,
      subject: "[PREVIEW] #{@subject}"
    )
  end
end 