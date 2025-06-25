class CustomerService
  def initialize(email, customer_params = {})
    @email = email.downcase.strip
    @customer_params = customer_params
  end

  def find_or_create_customer
    user = User.find_by(email: @email)
    
    if user
      # Update existing customer with new information if provided
      update_customer_info(user) if customer_params_present?
      user
    else
      # Create new customer
      create_customer
    end
  end

  def create_customer
    user = User.new(
      email: @email,
      user_type: 'customer',
      first_name: @customer_params[:first_name],
      last_name: @customer_params[:last_name],
      phone: @customer_params[:phone],
      address: @customer_params[:address],
      newsletter_subscribed: @customer_params[:newsletter_subscribed] || false
    )

    # Skip password validation for customers
    user.save(validate: false)
    user
  end

  def update_customer_info(user)
    user.update(
      first_name: @customer_params[:first_name] || user.first_name,
      last_name: @customer_params[:last_name] || user.last_name,
      phone: @customer_params[:phone] || user.phone,
      address: @customer_params[:address] || user.address,
      newsletter_subscribed: @customer_params[:newsletter_subscribed] || user.newsletter_subscribed
    )
  end

  def self.find_by_email(email)
    User.customers.find_by(email: email.downcase.strip)
  end

  def self.newsletter_subscribers
    User.newsletter_subscribers
  end

  private

  def customer_params_present?
    # Convert to hash if it's ActionController::Parameters, otherwise use as is
    params_hash = @customer_params.respond_to?(:to_unsafe_h) ? @customer_params.to_unsafe_h : @customer_params
    params_hash.any? { |key, value| value.present? }
  end
end 