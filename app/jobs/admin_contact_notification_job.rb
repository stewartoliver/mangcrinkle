class AdminContactNotificationJob < ApplicationJob
  queue_as :default
  
  def perform(contact_message_id, admin_id)
    contact_message = ContactMessage.find(contact_message_id)
    admin = User.find(admin_id)
    
    unless admin.admin?
      Rails.logger.error "AdminContactNotificationJob failed: User #{admin_id} is not an admin"
      return
    end
    
    AdminMailer.new_contact_message(contact_message, admin).deliver_now
    Rails.logger.info "Admin contact notification email sent for message #{contact_message_id} to admin #{admin_id}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "AdminContactNotificationJob failed: ContactMessage #{contact_message_id} or Admin #{admin_id} not found - #{e.message}"
  rescue => e
    Rails.logger.error "AdminContactNotificationJob failed: #{e.message}"
    raise e
  end
end
