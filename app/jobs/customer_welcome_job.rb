class CustomerWelcomeJob < ApplicationJob
  queue_as :default
  
  def perform(user_id)
    user = User.find(user_id)
    
    unless user.customer?
      Rails.logger.error "CustomerWelcomeJob failed: User #{user_id} is not a customer"
      return
    end
    
    CustomerMailer.welcome_email(user).deliver_now
    Rails.logger.info "Welcome email sent for customer #{user_id}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "CustomerWelcomeJob failed: User #{user_id} not found - #{e.message}"
  rescue => e
    Rails.logger.error "CustomerWelcomeJob failed: #{e.message}"
    raise e
  end
end
