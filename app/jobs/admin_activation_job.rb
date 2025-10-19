class AdminActivationJob < ApplicationJob
  queue_as :default
  
  def perform(user_id)
    user = User.find(user_id)
    
    unless user.admin?
      Rails.logger.error "AdminActivationJob failed: User #{user_id} is not an admin"
      return
    end

    if user.activated?
      Rails.logger.warn "AdminActivationJob skipped: User #{user_id} is already activated"
      return
    end
    
    # Use deliver_later for better performance and to avoid blocking the request
    AdminMailer.admin_activation(user).deliver_later
    Rails.logger.info "Admin activation email queued for user #{user_id}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "AdminActivationJob failed: User #{user_id} not found - #{e.message}"
  rescue => e
    Rails.logger.error "AdminActivationJob failed: #{e.message}"
    raise e
  end
end
