Recaptcha.configure do |config|
  config.site_key = ENV['RECAPTCHA_SITE_KEY']
  config.secret_key = ENV['RECAPTCHA_SECRET_KEY']
  
  # Disable reCAPTCHA in development and test environments
  if Rails.env.development? || Rails.env.test? || 
     ENV['RECAPTCHA_SITE_KEY'].blank? || ENV['RECAPTCHA_SECRET_KEY'].blank?
    config.skip_verify_env = ['development', 'test']
  end
end

# Helper methods for reCAPTCHA
module RecaptchaHelper
  def show_recaptcha?
    # Debug logging (safe - no key values)
    Rails.logger.info "🔍 reCAPTCHA Debug - Request path: #{request.path}"
    Rails.logger.info "🔍 reCAPTCHA Debug - Request host: #{request.host}"
    Rails.logger.info "🔍 reCAPTCHA Debug - Rails env: #{Rails.env}"
    Rails.logger.info "🔍 reCAPTCHA Debug - Site key present: #{ENV['RECAPTCHA_SITE_KEY'].present?}"
    Rails.logger.info "🔍 reCAPTCHA Debug - Secret key present: #{ENV['RECAPTCHA_SECRET_KEY'].present?}"
    
    # Don't show reCAPTCHA in admin routes
    if request.path.start_with?('/admin')
      Rails.logger.info "🔍 reCAPTCHA Debug - Skipping: admin route"
      return false
    end
    
    # Don't show reCAPTCHA in development/test or when keys are missing
    if Rails.env.development? || Rails.env.test?
      Rails.logger.info "🔍 reCAPTCHA Debug - Skipping: dev/test environment"
      return false
    end
    
    if ENV['RECAPTCHA_SITE_KEY'].blank? || ENV['RECAPTCHA_SECRET_KEY'].blank?
      Rails.logger.info "🔍 reCAPTCHA Debug - Skipping: missing keys"
      return false
    end
    
    # Don't show on localhost
    if request.host.include?('localhost') || request.host.include?('127.0.0.1')
      Rails.logger.info "🔍 reCAPTCHA Debug - Skipping: localhost"
      return false
    end
    
    Rails.logger.info "🔍 reCAPTCHA Debug - Showing reCAPTCHA: TRUE"
    true
  end
  
  def verify_recaptcha_if_needed(model = nil)
    # Skip reCAPTCHA verification in admin routes
    return true if request.path.start_with?('/admin')
    
    # Skip verification if reCAPTCHA shouldn't be shown
    return true unless show_recaptcha?
    
    # For reCAPTCHA v3, verify without action parameter
    verify_recaptcha(model: model)
  end
end

# Include helpers in ApplicationController
Rails.application.config.to_prepare do
  ApplicationController.include RecaptchaHelper
  ApplicationController.helper_method :show_recaptcha?, :verify_recaptcha_if_needed
end 