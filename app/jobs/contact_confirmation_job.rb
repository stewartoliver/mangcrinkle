class ContactConfirmationJob < ApplicationJob
  queue_as :default
  
  def perform(contact_message_id)
    contact_message = ContactMessage.find(contact_message_id)
    
    CustomerMailer.contact_confirmation(contact_message).deliver_now
    Rails.logger.info "Contact confirmation email sent for message #{contact_message_id}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "ContactConfirmationJob failed: ContactMessage #{contact_message_id} not found - #{e.message}"
  rescue => e
    Rails.logger.error "ContactConfirmationJob failed: #{e.message}"
    raise e
  end
end
