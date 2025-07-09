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

  # Test email methods with sample data
  def test_order_confirmation(test_email)
    @order = OpenStruct.new(
      id: 12345,
      total_price: 29.99,
      email: test_email,
      customer_name: "Test Customer",
      created_at: Time.current,
      address: "123 Test Street\nTest City, TC 12345\nNew Zealand",
      line_items: [
        OpenStruct.new(
          quantity: 6, 
          purchasable: OpenStruct.new(name: "Classic Chocolate Crinkles"),
          price: 18.00
        ),
        OpenStruct.new(
          quantity: 3, 
          purchasable: OpenStruct.new(name: "Peanut Butter Crinkles"),
          price: 11.99
        )
      ],
      user: OpenStruct.new(display_name: "Test Customer"),
      delivery_address: "123 Test Street, Test City, TC 12345",
      delivery_date: Date.current + 2.days,
      order_notes: "Please ring doorbell"
    )
    @user = @order.user
    @customer_name = @order.customer_name
    
    mail(to: test_email, subject: "[TEST] Your Mang Crinkle Order ##{@order.id} is Confirmed! 🎉", template_name: 'order_confirmation')
  end

  def test_welcome_email(test_email)
    @user = OpenStruct.new(
      display_name: "Test Customer",
      email: test_email
    )
    @customer_name = @user.display_name
    
    mail(to: test_email, subject: "[TEST] Welcome to the Mang Crinkle Family! 🍪", template_name: 'welcome_email')
  end

  def test_newsletter_email(test_email)
    @user = OpenStruct.new(
      display_name: "Test Customer",
      email: test_email
    )
    @customer_name = @user.display_name
    @subject = "[TEST] Fresh Crinkles & Family Updates from Mang! 🍪"
    @body = "Test newsletter content with exciting updates about our latest cookie flavors and family stories!"
    
    mail(to: test_email, subject: @subject, template_name: 'newsletter_email')
  end

  def test_contact_response(test_email)
    @contact_message = OpenStruct.new(
      subject: "Question about cookie ingredients",
      message: "Hi, I wanted to ask about the ingredients in your chocolate crinkles. Are they gluten-free?",
      created_at: 1.day.ago
    )
    @user = OpenStruct.new(
      display_name: "Test Customer",
      email: test_email
    )
    @admin_response = OpenStruct.new(
      response: "Thank you for your question! Our classic chocolate crinkles do contain gluten as they're made with wheat flour. However, we're working on a gluten-free version that should be available next month. I'll keep you updated!",
      admin_name: "Maria Santos",
      created_at: Time.current
    )
    @customer_name = @user.display_name
    
    mail(to: test_email, subject: "[TEST] Re: Question about cookie ingredients", template_name: 'contact_response')
  end

  def test_shipping_confirmation(test_email)
    @order = OpenStruct.new(
      id: 12345,
      total_price: 29.99,
      email: test_email,
      customer_name: "Test Customer",
      tracking_number: "MC123456789",
      estimated_delivery: Date.current + 2.days,
      carrier: "Local Delivery",
      created_at: 1.week.ago,
      address: "123 Test Street\nTest City, TC 12345\nNew Zealand",
      line_items: [
        OpenStruct.new(
          quantity: 6, 
          purchasable: OpenStruct.new(name: "Classic Chocolate Crinkles"),
          price: 18.00
        ),
        OpenStruct.new(
          quantity: 3, 
          purchasable: OpenStruct.new(name: "Peanut Butter Crinkles"),
          price: 11.99
        )
      ],
      user: OpenStruct.new(display_name: "Test Customer"),
      delivery_address: "123 Test Street, Test City, TC 12345"
    )
    @user = @order.user
    @customer_name = @order.customer_name
    
    mail(to: test_email, subject: "[TEST] Your Mang Crinkle Order is on its Way! 🚚", template_name: 'shipping_confirmation')
  end

  private

  def order_items_summary(order)
    order.line_items.map do |item|
      "#{item.quantity}x #{item.purchasable.name}"
    end.join(", ")
  end

  # Helper method to ensure company_name is available in mailer context
  def company_name
    @company_name ||= Company.main.name.presence || 'Mang Crinkle Cookies'
  end
  helper_method :company_name

  # Helper method to ensure company_email is available in mailer context
  def company_email
    @company_email ||= Company.main.email.presence || 'info@mangcrinkle.com'
  end
  helper_method :company_email
end 