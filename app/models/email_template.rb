class EmailTemplate < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :subject, presence: true
  validates :body, presence: true
  validates :template_type, presence: true, inclusion: { 
    in: %w[welcome order_confirmation newsletter contact_response contact_confirmation new_order_notification admin_activation admin_password_reset sales_report manual] 
  }

  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(template_type: type) }

  before_validation :set_defaults, on: :create

  def variable_list
    return [] if variables.blank?
    variables.split(',').map(&:strip)
  end

  def variable_list=(vars)
    self.variables = Array(vars).join(', ')
  end

  def render_with_variables(vars = {})
    rendered_subject = subject.dup
    rendered_body = body.dup

    vars.each do |key, value|
      placeholder = "{{#{key}}}"
      rendered_subject.gsub!(placeholder, value.to_s)
      rendered_body.gsub!(placeholder, value.to_s)
    end

    {
      subject: rendered_subject,
      body: rendered_body
    }
  end

  def self.template_types
    %w[welcome order_confirmation newsletter contact_response contact_confirmation new_order_notification admin_activation admin_password_reset sales_report manual]
  end

  def self.default_templates
    {
      'welcome' => {
        name: 'Welcome Email',
        subject: 'Welcome to Mang Crinkle Cookies! 🍪',
        body: 'Hi {{customer_name}},

Welcome to the Mang Crinkle family! We\'re excited to have you join us.

You\'ll receive updates about new flavors, special offers, and baking tips from Mang himself.

Thanks for subscribing!

With love and crinkles,
The Mang Crinkle Team',
        variables: 'customer_name, customer_email'
      },
      'order_confirmation' => {
        name: 'Order Confirmation',
        subject: 'Your Mang Crinkle Order #{{order_number}} is Confirmed! 🎉',
        body: 'Hi {{customer_name}},

Thank you for your order! We\'re excited to bake your delicious crinkles.

Order Details:
- Order Number: #{{order_number}}
- Total: ${{order_total}}
- Items: {{order_items}}

We\'ll send you another email when your order ships.

Thanks for choosing Mang Crinkles!

With love,
The Mang Crinkle Team',
        variables: 'customer_name, order_number, order_total, order_items, customer_email'
      },
      'contact_response' => {
        name: 'Contact Response',
        subject: 'Re: {{original_subject}}',
        body: 'Hi {{customer_name}},

Thanks for reaching out to us! Here\'s our response:

{{admin_response}}

If you have any other questions, please don\'t hesitate to contact us.

Best regards,
{{admin_name}}
Mang Crinkle Team',
        variables: 'customer_name, original_subject, admin_response, admin_name'
      },
      'contact_confirmation' => {
        name: 'Contact Form Confirmation',
        subject: 'We\'ve received your message - {{subject}}',
        body: 'Hi {{customer_name}},

Thank you for contacting us! We\'ve received your message about "{{subject}}" and wanted to confirm that it\'s safely in our inbox.

Message Details:
- Subject: {{subject}}
- Priority: {{priority}}

What happens next?
✓ Our team has been notified and will review your message
✓ We typically respond within 24 hours during business days
✓ High priority messages are handled even faster

We really appreciate you taking the time to contact us. Whether you have questions about our delicious crinkle cookies, need help with an order, or just want to share some feedback, we\'re here to help!

With love and fresh-baked goodness,
The Mang Crinkle Team',
        variables: 'customer_name, subject, priority'
      },
      'new_order_notification' => {
        name: 'New Order Notification (Admin)',
        subject: 'New Order #{{order_number}} - {{customer_name}} - ${{order_total}}',
        body: 'Hello {{admin_name}},

A new order has been received and is ready for processing.

Order Summary:
- Order ID: #{{order_number}}
- Customer: {{customer_name}}
- Email: {{customer_email}}
- Total: ${{order_total}}
- Status: {{order_status}}

Items Ordered:
{{order_items}}

Please review and process this order in the admin panel.

Order received at: {{order_date}}',
        variables: 'admin_name, order_number, customer_name, customer_email, order_total, order_status, order_items, order_date'
      },
      'admin_activation' => {
        name: 'Admin Account Activation',
        subject: 'Welcome to Mang Crinkle Admin - Set Up Your Password',
        body: 'Hello {{admin_name}},

Welcome to the Mang Crinkle admin team! Your administrator account has been created and you need to set up your password to get started.

Click the link below to activate your account and set your password:
{{activation_url}}

This link will expire in 24 hours for security reasons.

If you have any questions about using the admin system, don\'t hesitate to reach out to the team.

Welcome aboard!

The Mang Crinkle Team',
        variables: 'admin_name, activation_url'
      },
      'admin_password_reset' => {
        name: 'Admin Password Reset',
        subject: 'Mang Crinkle Admin - Password Reset Request',
        body: 'Hello {{admin_name}},

A password reset has been requested for your Mang Crinkle admin account.

Click the link below to reset your password:
{{reset_url}}

This link will expire in 2 hours for security reasons.

If you didn\'t request this password reset, please ignore this email. Your password will remain unchanged.

The Mang Crinkle Team',
        variables: 'admin_name, reset_url'
      }
    }
  end

  private

  def set_defaults
    self.active = true if active.nil?
    self.template_type ||= 'manual'
  end
end
