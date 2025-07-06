class EmailTemplate < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :subject, presence: true
  validates :body, presence: true
  validates :template_type, presence: true, inclusion: { 
    in: %w[welcome order_confirmation newsletter contact_response sales_report manual] 
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
    %w[welcome order_confirmation newsletter contact_response sales_report manual]
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
      }
    }
  end

  private

  def set_defaults
    self.active = true if active.nil?
    self.template_type ||= 'manual'
  end
end
