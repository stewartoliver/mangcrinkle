class Admin::EmailTemplatesController < Admin::BaseController
  before_action :set_email_template, only: [:show, :edit, :update, :destroy, :preview]
  before_action :set_hardcoded_template, only: [:show_hardcoded, :send_test_email]

  def index
    @email_templates = EmailTemplate.order(:template_type, :name)
    @hardcoded_templates = hardcoded_email_templates
    @template_types = EmailTemplate.template_types
  end

  def show
  end

  def show_hardcoded
    @template_content = File.read(Rails.root.join(@hardcoded_template[:path]))
    @rendered_template = render_hardcoded_template_with_sample_data
  rescue Errno::ENOENT
    redirect_to admin_email_templates_path, alert: 'Template file not found.'
  end

  def send_test_email
    test_email = params[:test_email]
    
    if test_email.blank?
      redirect_to show_hardcoded_admin_email_templates_path(template_path: @hardcoded_template[:path]), 
                  alert: 'Please enter a valid email address.'
      return
    end

    unless test_email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
      redirect_to show_hardcoded_admin_email_templates_path(template_path: @hardcoded_template[:path]), 
                  alert: 'Please enter a valid email address.'
      return
    end

    begin
      # Send test email based on template type
      case @hardcoded_template[:template_type]
      when 'admin_activation'
        # Use the test method that doesn't try to save the user
        AdminMailer.test_admin_activation(test_email, current_admin_user).deliver_now
      when 'order_confirmation'
        # Use the sample order data
        sample_order = create_sample_order_for_email(test_email)
        CustomerMailer.order_confirmation(sample_order).deliver_now
      when 'welcome'
        # Use the sample user data
        sample_user = create_sample_user_for_email(test_email)
        CustomerMailer.welcome_email(sample_user).deliver_now
      when 'review_invite'
        # Use the sample review invite data
        sample_review_invite = create_sample_review_invite_for_email(test_email)
        ReviewMailer.review_invite(sample_review_invite).deliver_now
      when 'review_notification'
        # Use the sample review data
        sample_review = create_sample_review_for_email(test_email)
        ReviewMailer.new_review_notification(sample_review).deliver_now
      when 'newsletter'
        # Use the sample user data
        sample_user = create_sample_user_for_email(test_email)
        CustomerMailer.newsletter_email(sample_user, "New Flavors This Month!", "Check out our latest seasonal treats including limited-time Buko Pie and refreshing Halo-Halo cookies!").deliver_now
      when 'contact_response'
        # Use the sample contact response data
        sample_contact = create_sample_contact_for_email(test_email)
        sample_response = create_sample_response_for_email
        CustomerMailer.contact_response(sample_contact, sample_response).deliver_now
      when 'shipping_confirmation'
        # Use the sample order data - need to add shipping details
        sample_order = create_sample_order_for_email(test_email)
        sample_order.define_singleton_method(:tracking_number) { 'TRK-9876543210' }
        sample_order.define_singleton_method(:shipping_company) { 'FedEx' }
        sample_order.define_singleton_method(:carrier) { 'FedEx' }
        sample_order.define_singleton_method(:estimated_delivery) { Date.current + 2.days }
        CustomerMailer.shipping_confirmation(sample_order).deliver_now
      else
        redirect_to show_hardcoded_admin_email_templates_path(template_path: @hardcoded_template[:path]), 
                    alert: 'Test email not supported for this template type.'
        return
      end

      redirect_to show_hardcoded_admin_email_templates_path(template_path: @hardcoded_template[:path]), 
                  notice: Rails.env.development? ? 
                          "Test email generated successfully! Check your browser for the email preview." : 
                          "Test email sent successfully to #{test_email}!"
    rescue => e
      Rails.logger.error "Failed to send test email: #{e.message}"
      redirect_to show_hardcoded_admin_email_templates_path(template_path: @hardcoded_template[:path]), 
                  alert: 'Failed to send test email. Please try again.'
    end
  end

  def new
    @email_template = EmailTemplate.new
  end

  def create
    @email_template = EmailTemplate.new(email_template_params)
    
    if @email_template.save
      redirect_to admin_email_template_path(@email_template), notice: 'Email template created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @email_template.update(email_template_params)
      redirect_to admin_email_template_path(@email_template), notice: 'Email template updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @email_template.destroy
    redirect_to admin_email_templates_path, notice: 'Email template deleted successfully.'
  end

  def preview
    variables = parse_preview_variables(params[:variables])
    
    if request.post?
      # Send preview email
      AdminMailer.template_preview(current_admin_user, @email_template, variables).deliver_later
      redirect_to admin_email_template_path(@email_template), notice: 'Preview email sent!'
    else
      # Show preview form
      @rendered = @email_template.render_with_variables(variables)
      @sample_variables = generate_sample_variables_for_template(@email_template)
    end
  end

  def seed_defaults
    EmailTemplate.default_templates.each do |template_type, template_data|
      next if EmailTemplate.find_by(template_type: template_type)
      
      EmailTemplate.create!(
        template_type: template_type,
        name: template_data[:name],
        subject: template_data[:subject],
        body: template_data[:body],
        variables: template_data[:variables],
        active: true
      )
    end
    
    redirect_to admin_email_templates_path, notice: 'Default templates created successfully.'
  end

  private

  def set_email_template
    @email_template = EmailTemplate.find(params[:id])
  end

  def set_hardcoded_template
    @hardcoded_template = hardcoded_email_templates.find { |t| t[:path] == params[:template_path] }
    redirect_to admin_email_templates_path, alert: 'Template not found.' unless @hardcoded_template
  end

  def hardcoded_email_templates
    [
      {
        name: 'Admin Activation Email',
        template_type: 'admin_activation',
        subject: 'Welcome to Mang Crinkle Admin',
        path: 'app/views/admin_mailer/admin_activation.html.erb',
        description: 'Email sent to new admin users for account activation',
        variables: ['admin_user.display_name', 'admin_user.email', 'activation_url'],
        active: true,
        hardcoded: true
      },
      {
        name: 'Admin Password Reset Email',
        template_type: 'admin_password_reset',
        subject: 'Mang Crinkle Admin - Password Reset Request',
        path: 'app/views/admin_mailer/admin_password_reset.html.erb',
        description: 'Email sent to admin users for password reset',
        variables: ['admin_user.display_name', 'admin_user.email', 'reset_url'],
        active: true,
        hardcoded: true
      },
      {
        name: 'Order Confirmation Email',
        template_type: 'order_confirmation',
        subject: 'Order Confirmation',
        path: 'app/views/customer_mailer/order_confirmation.html.erb',
        description: 'Email sent to customers when they place an order',
        variables: ['order', 'order.user.display_name', 'order.customer_name', 'order.id', 'order.total_price', 'order.line_items'],
        active: true,
        hardcoded: true
      },
      {
        name: 'Welcome Email',
        template_type: 'welcome',
        subject: 'Welcome to the Family!',
        path: 'app/views/customer_mailer/welcome_email.html.erb',
        description: 'Email sent to new customers when they sign up',
        variables: ['customer_name', 'user.email'],
        active: true,
        hardcoded: true
      },
      {
        name: 'Review Invitation Email',
        template_type: 'review_invite',
        subject: 'Share Your Mang Crinkle Experience',
        path: 'app/views/review_mailer/review_invite.html.erb',
        description: 'Email sent to customers inviting them to leave a review',
        variables: ['customer_name', 'order', 'review_url', 'review_invite.email'],
        active: true,
        hardcoded: true
      },
      {
        name: 'New Review Notification',
        template_type: 'review_notification',
        subject: 'New Review Submitted - Mang Crinkle',
        path: 'app/views/review_mailer/new_review_notification.html.erb',
        description: 'Email sent to admins when a new review is submitted',
        variables: ['review', 'review.customer_display_name', 'review.email', 'review.rating', 'review.title', 'review.content'],
        active: true,
        hardcoded: true
      },
      {
        name: 'Newsletter Email',
        template_type: 'newsletter',
        subject: 'Newsletter',
        path: 'app/views/customer_mailer/newsletter_email.html.erb',
        description: 'Email template for newsletter campaigns',
        variables: ['customer_name', 'body', 'user.email'],
        active: true,
        hardcoded: true
      },
      {
        name: 'Contact Response Email',
        template_type: 'contact_response',
        subject: 'Response to Your Inquiry',
        path: 'app/views/customer_mailer/contact_response.html.erb',
        description: 'Email template for responding to customer inquiries',
        variables: ['customer_name', 'body', 'contact_message', 'admin_response', 'user.email'],
        active: true,
        hardcoded: true
      },
      {
        name: 'Shipping Confirmation Email',
        template_type: 'shipping_confirmation',
        subject: 'Your Mang Crinkle Order is on its Way!',
        path: 'app/views/customer_mailer/shipping_confirmation.html.erb',
        description: 'Email sent to customers when their order has shipped',
        variables: ['order', 'order.user.display_name', 'order.customer_name', 'order.id', 'order.total_price', 'order.line_items'],
        active: true,
        hardcoded: true
      }
    ]
  end

  def email_template_params
    params.require(:email_template).permit(:name, :subject, :body, :template_type, :variables, :active)
  end

  def parse_preview_variables(variables_param)
    return {} if variables_param.blank?
    
    # Handle hash parameters (from preview form)
    if variables_param.is_a?(ActionController::Parameters)
      return variables_param.permit!.to_h.stringify_keys
    elsif variables_param.is_a?(Hash)
      return variables_param.stringify_keys
    end
    
    # Handle comma-separated string format (legacy)
    if variables_param.is_a?(String)
      variables = {}
      variables_param.split(',').each do |var|
        key, value = var.split('=', 2)
        variables[key.strip] = value.strip if key && value
      end
      return variables
    end
    
    {}
  end

  def generate_sample_variables_for_template(template)
    case template.template_type
    when 'order_confirmation'
      {
        'customer_name' => 'John Doe',
        'order_number' => '12345',
        'order_total' => '$25.99',
        'items' => '12 Mixed Crinkles'
      }
    when 'shipping_notification'
      {
        'customer_name' => 'Jane Smith',
        'order_number' => '67890',
        'tracking_number' => 'TR123456789',
        'estimated_delivery' => '2024-01-15'
      }
    when 'review_request'
      {
        'customer_name' => 'Bob Johnson',
        'order_number' => '54321',
        'review_link' => 'https://example.com/review'
      }
    else
      {}
    end
  end

  def render_hardcoded_template_with_sample_data
    case @hardcoded_template[:template_type]
    when 'admin_activation'
      render_admin_activation_sample
    when 'admin_password_reset'
      render_admin_password_reset_sample
    when 'order_confirmation'
      render_order_confirmation_sample
    when 'welcome'
      render_welcome_sample
    when 'review_invite'
      render_review_invite_sample
    when 'review_notification'
      render_review_notification_sample
    when 'newsletter'
      render_newsletter_sample
    when 'contact_response'
      render_contact_response_sample
    when 'shipping_confirmation'
      render_shipping_confirmation_sample
    else
      nil
    end
  rescue => e
    Rails.logger.error "Error rendering email template: #{e.message}"
    nil
  end

  def render_admin_activation_sample
    sample_admin = OpenStruct.new(
      display_name: 'John Admin',
      email: 'john@example.com'
    )
    
    render_to_string(
      template: 'admin_mailer/admin_activation',
      layout: false,
      assigns: {
        admin_user: sample_admin,
        activation_url: 'https://example.com/admin/activate/sample-token'
      }
    )
  end

  def render_admin_password_reset_sample
    sample_admin = OpenStruct.new(
      display_name: 'John Admin',
      email: 'john@example.com'
    )
    
    render_to_string(
      template: 'admin_mailer/admin_password_reset',
      layout: false,
      assigns: {
        admin_user: sample_admin,
        reset_url: 'https://example.com/admin/password/reset/sample-token'
      }
    )
  end

  def render_order_confirmation_sample
    sample_user = OpenStruct.new(
      display_name: 'Jane Customer',
      email: 'jane@example.com'
    )
    
    sample_order = OpenStruct.new(
      id: 'ORD-12345',
      customer_name: 'Jane Customer',
      total_price: 45.99,
      user: sample_user,
      line_items: [
        OpenStruct.new(
          name: 'Ube Cookies (6-pack)', 
          quantity: 2, 
          price: 18.99,
          purchasable: OpenStruct.new(name: 'Ube Cookies (6-pack)')
        ),
        OpenStruct.new(
          name: 'Pandan Cake Slice', 
          quantity: 1, 
          price: 8.99,
          purchasable: OpenStruct.new(name: 'Pandan Cake Slice')
        )
      ],
      shipping_address: "123 Main St\nSample City, ST 12345",
      status: 'confirmed',
      created_at: Time.current,
      email: 'jane@example.com',
      address: "123 Main St\nSample City, ST 12345",
      delivery_address: "123 Main St\nSample City, ST 12345",
      delivery_date: Date.current + 2.days,
      order_notes: "Please ring doorbell"
    )
    
    render_to_string(
      template: 'customer_mailer/order_confirmation',
      layout: false,
      assigns: {
        order: sample_order,
        customer_name: sample_order.customer_name,
        user: sample_user,
        subject: 'Order Confirmation - #ORD-12345'
      }
    )
  end

  def render_welcome_sample
    sample_user = OpenStruct.new(
      display_name: 'Jane Customer',
      email: 'jane@example.com'
    )
    
    render_to_string(
      template: 'customer_mailer/welcome_email',
      layout: false,
      assigns: {
        customer_name: 'Jane Customer',
        user: sample_user,
        subject: 'Welcome to the Family!',
        body: "Thank you for joining our community! We're excited to share our delicious Filipino treats with you."
      }
    )
  end

  def render_review_invite_sample
    sample_order = OpenStruct.new(
      id: 'ORD-12345',
      customer_name: 'Jane Customer',
      total_price: 29.99,
      created_at: 1.week.ago,
      line_items: [
        OpenStruct.new(
          quantity: 6, 
          purchasable: OpenStruct.new(name: "Classic Chocolate Crinkles")
        ),
        OpenStruct.new(
          quantity: 3, 
          purchasable: OpenStruct.new(name: "Peanut Butter Crinkles")
        )
      ]
    )
    
    sample_review_invite = OpenStruct.new(
      name: 'Jane Customer',
      email: 'jane@example.com',
      token: 'sample-token-123',
      expires_at: 30.days.from_now,
      order: sample_order
    )
    
    # Add the review_url method that the template expects
    sample_review_invite.define_singleton_method(:review_url) do
      "https://example.com/reviews/new?token=#{token}"
    end
    
    render_to_string(
      template: 'review_mailer/review_invite',
      layout: false,
      assigns: {
        customer_name: 'Jane Customer',
        order: sample_order,
        review_url: 'https://example.com/reviews/new?order=ORD-12345',
        review_invite: sample_review_invite
      }
    )
  end

  def render_review_notification_sample
    sample_review = OpenStruct.new(
      customer_display_name: 'Jane Customer',
      customer_name: 'Jane Customer',
      email: 'jane@example.com',
      rating: 5,
      title: 'Amazing cookies!',
      content: 'Amazing cookies! The ube flavor is incredible and they arrived fresh. Will definitely order again!',
      comment: 'Amazing cookies! The ube flavor is incredible and they arrived fresh. Will definitely order again!',
      product_name: 'Ube Cookies (6-pack)',
      verified_purchase?: true,
      created_at: Time.current,
      order: OpenStruct.new(id: 12345)
    )
    
    render_to_string(
      template: 'review_mailer/new_review_notification',
      layout: false,
      assigns: {
        review: sample_review,
        admin_name: 'Admin User'
      }
    )
  end

  def render_newsletter_sample
    sample_user = OpenStruct.new(
      display_name: 'Jane Customer',
      email: 'jane@example.com'
    )
    
    render_to_string(
      template: 'customer_mailer/newsletter_email',
      layout: false,
      assigns: {
        customer_name: 'Jane Customer',
        user: sample_user,
        subject: 'New Flavors This Month!',
        body: "Check out our latest seasonal treats including limited-time Buko Pie and refreshing Halo-Halo cookies!"
      }
    )
  end

  def render_contact_response_sample
    sample_contact = OpenStruct.new(
      subject: 'Question about ingredients',
      message: 'Hi, I wanted to ask about the ingredients in your chocolate crinkles. Are they gluten-free?',
      user: OpenStruct.new(display_name: 'Jane Customer', email: 'jane@example.com'),
      created_at: 1.day.ago
    )
    
    sample_response = OpenStruct.new(
      response: 'Hi Jane! Thanks for your question about our ingredients. All our cookies are made with natural ingredients and we can accommodate most dietary restrictions. Please let us know if you have any specific concerns!',
      admin_name: 'Customer Service Team',
      created_at: Time.current
    )
    
    render_to_string(
      template: 'customer_mailer/contact_response',
      layout: false,
      assigns: {
        contact_message: sample_contact,
        admin_response: sample_response,
        customer_name: 'Jane Customer',
        user: sample_contact.user,
        subject: 'Re: Question about ingredients'
      }
    )
  end

  def render_shipping_confirmation_sample
    sample_user = OpenStruct.new(
      display_name: 'Jane Customer',
      email: 'jane@example.com'
    )
    
    sample_order = OpenStruct.new(
      id: 'ORD-12345',
      customer_name: 'Jane Customer',
      tracking_number: 'TRK-9876543210',
      shipping_company: 'FedEx',
      carrier: 'FedEx',
      estimated_delivery: Date.current + 2.days,
      user: sample_user,
      email: 'jane@example.com',
      total_price: 45.99,
      created_at: 1.week.ago,
      address: "123 Main St\nSample City, ST 12345",
      delivery_address: "123 Main St\nSample City, ST 12345",
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
      ]
    )
    
    render_to_string(
      template: 'customer_mailer/shipping_confirmation',
      layout: false,
      assigns: {
        order: sample_order,
        customer_name: sample_order.customer_name,
        user: sample_user,
        subject: 'Your Order Has Shipped! - #ORD-12345'
      }
    )
  end

  def create_sample_order_for_email(email)
    sample_user = OpenStruct.new(
      display_name: 'Jane Customer',
      email: email
    )
    
    OpenStruct.new(
      id: 'ORD-12345',
      customer_name: 'Jane Customer',
      total_price: 45.99,
      user: sample_user,
      line_items: [
        OpenStruct.new(
          name: 'Ube Cookies (6-pack)', 
          quantity: 2, 
          price: 18.99,
          purchasable: OpenStruct.new(name: 'Ube Cookies (6-pack)')
        ),
        OpenStruct.new(
          name: 'Pandan Cake Slice', 
          quantity: 1, 
          price: 8.99,
          purchasable: OpenStruct.new(name: 'Pandan Cake Slice')
        )
      ],
      shipping_address: "123 Main St\nSample City, ST 12345",
      status: 'confirmed',
      created_at: Time.current,
      email: email,
      address: "123 Main St\nSample City, ST 12345",
      delivery_address: "123 Main St\nSample City, ST 12345",
      delivery_date: Date.current + 2.days,
      order_notes: "Please ring doorbell"
    )
  end

  def create_sample_user_for_email(email)
    OpenStruct.new(
      display_name: 'Jane Customer',
      email: email
    )
  end

  def create_sample_review_invite_for_email(email)
    sample_order = OpenStruct.new(
      id: 'ORD-12345',
      customer_name: 'Jane Customer',
      total_price: 29.99,
      created_at: 1.week.ago,
      line_items: [
        OpenStruct.new(
          quantity: 6, 
          purchasable: OpenStruct.new(name: "Classic Chocolate Crinkles")
        ),
        OpenStruct.new(
          quantity: 3, 
          purchasable: OpenStruct.new(name: "Peanut Butter Crinkles")
        )
      ]
    )
    
    sample_review_invite = OpenStruct.new(
      name: 'Jane Customer',
      email: email,
      token: 'sample-token-123',
      expires_at: 30.days.from_now,
      order: sample_order
    )
    
    # Add the review_url method that the template expects
    sample_review_invite.define_singleton_method(:review_url) do
      "https://example.com/reviews/new?token=#{token}"
    end
    
    sample_review_invite
  end

  def create_sample_review_for_email(email)
    OpenStruct.new(
      customer_display_name: 'Jane Customer',
      customer_name: 'Jane Customer',
      email: email,
      rating: 5,
      title: 'Amazing cookies!',
      content: 'Amazing cookies! The ube flavor is incredible and they arrived fresh. Will definitely order again!',
      comment: 'Amazing cookies! The ube flavor is incredible and they arrived fresh. Will definitely order again!',
      product_name: 'Ube Cookies (6-pack)',
      verified_purchase?: true,
      created_at: Time.current,
      order: OpenStruct.new(id: 12345)
    )
  end

  def create_sample_contact_for_email(email)
    OpenStruct.new(
      subject: 'Question about ingredients',
      message: 'Hi, I wanted to ask about the ingredients in your chocolate crinkles. Are they gluten-free?',
      user: OpenStruct.new(display_name: 'Jane Customer', email: email),
      created_at: 1.day.ago
    )
  end

  def create_sample_response_for_email
    OpenStruct.new(
      response: 'Hi Jane! Thanks for your question about our ingredients. All our cookies are made with natural ingredients and we can accommodate most dietary restrictions. Please let us know if you have any specific concerns!',
      admin_name: 'Customer Service Team',
      created_at: Time.current
    )
  end

  def current_admin_user
    current_user
  end
end 