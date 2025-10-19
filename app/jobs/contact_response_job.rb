class ContactResponseJob < ApplicationJob
  queue_as :default
  
  def perform(contact_response_id)
    contact_response = ContactResponse.find(contact_response_id)
    
    # Use deliver_later for better performance and to avoid blocking the request
    ContactMailer.response_email(contact_response).deliver_later
    Rails.logger.info "Contact response email queued for response #{contact_response_id}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "ContactResponseJob failed: ContactResponse #{contact_response_id} not found - #{e.message}"
  rescue => e
    Rails.logger.error "ContactResponseJob failed: #{e.message}"
    raise e
  end
end
