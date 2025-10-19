class AdminPasswordResetJob < ApplicationJob
  queue_as :default
  
  def perform(user_id)
    user = User.find(user_id)
    
    unless user.admin?
      Rails.logger.error "AdminPasswordResetJob failed: User #{user_id} is not an admin"
      return
    end

    unless user.activated?
      Rails.logger.error "AdminPasswordResetJob failed: User #{user_id} is not activated"
      return
    end
    
    # Use deliver_later for better performance and to avoid blocking the request
    AdminMailer.admin_password_reset(user).deliver_later
    Rails.logger.info "Admin password reset email queued for user #{user_id}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "AdminPasswordResetJob failed: User #{user_id} not found - #{e.message}"
  rescue => e
    Rails.logger.error "AdminPasswordResetJob failed: #{e.message}"
    raise e
  end
end
