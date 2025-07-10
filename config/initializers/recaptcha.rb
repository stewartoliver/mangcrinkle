require 'google/cloud/recaptcha_enterprise'

# Configure standard reCAPTCHA for frontend
Recaptcha.configure do |config|
  config.site_key = ENV['RECAPTCHA_SITE_KEY']
  config.secret_key = ENV['RECAPTCHA_SECRET_KEY']
  
  # Disable reCAPTCHA in development and test environments
  if Rails.env.development? || Rails.env.test? || 
     ENV['RECAPTCHA_SITE_KEY'].blank? || ENV['RECAPTCHA_SECRET_KEY'].blank?
    config.skip_verify_env = ['development', 'test']
  end
end

# Google Cloud reCAPTCHA Enterprise client
module RecaptchaEnterpriseHelper
  def show_recaptcha?
    # Don't show reCAPTCHA in admin routes
    return false if request.path.start_with?('/admin')
    
    # Don't show reCAPTCHA in development/test or when keys are missing
    return false if Rails.env.development? || Rails.env.test?
    return false if ENV['RECAPTCHA_SITE_KEY'].blank? || ENV['RECAPTCHA_SECRET_KEY'].blank?
    return false if ENV['GOOGLE_CLOUD_PROJECT'].blank?
    
    # Don't show on localhost
    return false if request.host.include?('localhost') || request.host.include?('127.0.0.1')
    
    true
  end
  
  def verify_recaptcha_enterprise(token, action = 'form_submission')
    return true unless show_recaptcha?
    
    begin
      client = Google::Cloud::RecaptchaEnterprise.recaptcha_enterprise_service
      
      request = {
        parent: "projects/#{ENV['GOOGLE_CLOUD_PROJECT']}",
        assessment: {
          event: {
            site_key: ENV['RECAPTCHA_SITE_KEY'],
            token: token
          }
        }
      }
      
      response = client.create_assessment(request)
      
      # Check if token is valid
      unless response.token_properties.valid
        Rails.logger.error "reCAPTCHA Enterprise failed: #{response.token_properties.invalid_reason}"
        return false
      end
      
      # Check if action matches
      unless response.token_properties.action == action
        Rails.logger.error "reCAPTCHA action mismatch: expected #{action}, got #{response.token_properties.action}"
        return false
      end
      
      # Check risk score (adjust threshold as needed)
      score = response.risk_analysis.score
      Rails.logger.info "reCAPTCHA Enterprise score: #{score}"
      
      # Return true if score is above threshold (0.5 is a reasonable default)
      score >= 0.5
      
    rescue => e
      Rails.logger.error "reCAPTCHA Enterprise error: #{e.message}"
      # In production, you might want to return false here for security
      # For now, we'll return true to avoid blocking legitimate users during setup
      Rails.env.production? ? false : true
    end
  end
end

# Include helpers in ApplicationController
Rails.application.config.to_prepare do
  ApplicationController.include RecaptchaEnterpriseHelper
  ApplicationController.helper_method :show_recaptcha?
end 