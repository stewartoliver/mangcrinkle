class CustomerMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    @customer_name = user.display_name
    
    template = EmailTemplate.active.by_type('welcome').first
    if template
      rendered = template.render_with_variables(
        customer_name: @customer_name,
        customer_email: @user.email
      )
      @subject = rendered[:subject]
      @body = rendered[:body]
    else
      @subject = "Welcome to Mang Crinkle Cookies! 🍪"
      @body = "Hi #{@customer_name},\n\nWelcome to the Mang Crinkle family! We're excited to have you join us."
    end
    
    mail(to: @user.email, subject: @subject)
  end

  def order_confirmation(order)
    @order = order
    @user = order.user
    @customer_name = @user&.display_name || order.customer_name
    
    template = EmailTemplate.active.by_type('order_confirmation').first
    if template
      rendered = template.render_with_variables(
        customer_name: @customer_name,
        order_number: @order.id,
        order_total: number_to_currency(@order.total_price),
        order_items: order_items_summary(@order),
        customer_email: @order.email
      )
      @subject = rendered[:subject]
      @body = rendered[:body]
    else
      @subject = "Your Mang Crinkle Order ##{@order.id} is Confirmed! 🎉"
      @body = "Hi #{@customer_name},\n\nThank you for your order! We're excited to bake your delicious crinkles."
    end
    
    mail(to: @order.email, subject: @subject)
  end

  def contact_response(contact_message, admin_response)
    @contact_message = contact_message
    @user = contact_message.user
    @admin_response = admin_response
    @customer_name = @user.display_name
    
    template = EmailTemplate.active.by_type('contact_response').first
    if template
      rendered = template.render_with_variables(
        customer_name: @customer_name,
        original_subject: @contact_message.subject,
        admin_response: @admin_response.response,
        admin_name: @admin_response.admin_name
      )
      @subject = rendered[:subject]
      @body = rendered[:body]
    else
      @subject = "Re: #{@contact_message.subject}"
      @body = "Hi #{@customer_name},\n\nThanks for reaching out to us! Here's our response:\n\n#{@admin_response.response}"
    end
    
    mail(to: @user.email, subject: @subject)
  end

  def newsletter_email(user, subject, body)
    @user = user
    @customer_name = user.display_name
    @subject = subject
    @body = body
    
    mail(to: @user.email, subject: @subject)
  end

  private

  def order_items_summary(order)
    order.line_items.map do |item|
      "#{item.quantity}x #{item.purchasable.name}"
    end.join(', ')
  end
end 