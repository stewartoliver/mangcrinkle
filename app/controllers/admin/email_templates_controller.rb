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
        AdminMailer.test_admin_activation(test_email, current_admin_user).deliver_now
      when 'order_confirmation'
        CustomerMailer.test_order_confirmation(test_email).deliver_now
      when 'welcome'
        CustomerMailer.test_welcome_email(test_email).deliver_now
      when 'review_invite'
        ReviewMailer.test_review_invite(test_email).deliver_now
      when 'review_notification'
        ReviewMailer.test_new_review_notification(test_email).deliver_now
      when 'newsletter'
        CustomerMailer.test_newsletter_email(test_email).deliver_now
      when 'contact_response'
        CustomerMailer.test_contact_response(test_email).deliver_now
      when 'shipping_confirmation'
        CustomerMailer.test_shipping_confirmation(test_email).deliver_now
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

  def current_admin_user
    current_user
  end
end 