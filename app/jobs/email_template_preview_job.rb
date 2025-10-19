class EmailTemplatePreviewJob < ApplicationJob
  queue_as :default
  
  def perform(admin_user_id, email_template_id, variables = {})
    admin_user = User.find(admin_user_id)
    email_template = EmailTemplate.find(email_template_id)
    
    unless admin_user.admin?
      Rails.logger.error "EmailTemplatePreviewJob failed: User #{admin_user_id} is not an admin"
      return
    end
    
    AdminMailer.template_preview(admin_user, email_template, variables).deliver_now
    Rails.logger.info "Email template preview sent for template #{email_template_id} to admin #{admin_user_id}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "EmailTemplatePreviewJob failed: User #{admin_user_id} or EmailTemplate #{email_template_id} not found - #{e.message}"
  rescue => e
    Rails.logger.error "EmailTemplatePreviewJob failed: #{e.message}"
    raise e
  end
end
