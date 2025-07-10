Recaptcha.configure do |config|
  # Get reCAPTCHA keys from environment variables
  config.site_key = ENV['RECAPTCHA_SITE_KEY']
  config.secret_key = ENV['RECAPTCHA_SECRET_KEY']
  
  # Disable reCAPTCHA in development and test environments or when running on localhost
  if Rails.env.development? || Rails.env.test? || 
     ENV['RECAPTCHA_SITE_KEY'].blank? || ENV['RECAPTCHA_SECRET_KEY'].blank?
    config.skip_verify_env = ['development', 'test']
  end
end

# Helper method to check if reCAPTCHA should be shown
module RecaptchaHelper
  def show_recaptcha?
    # Don't show reCAPTCHA in admin routes
    return false if request.path.start_with?('/admin')
    
    # Don't show reCAPTCHA in development/test or when keys are missing
    return false if Rails.env.development? || Rails.env.test?
    return false if ENV['RECAPTCHA_SITE_KEY'].blank? || ENV['RECAPTCHA_SECRET_KEY'].blank?
    
    # Don't show on localhost (covers both development server and any localhost access)
    return false if request.host.include?('localhost') || request.host.include?('127.0.0.1')
    
    true
  end
  
  def verify_recaptcha_if_needed(model = nil)
    # Skip reCAPTCHA verification in admin routes
    return true if request.path.start_with?('/admin')
    
    # Skip verification if reCAPTCHA shouldn't be shown
    return true unless show_recaptcha?
    
    # For reCAPTCHA v3, verify without action parameter first
    verify_recaptcha(model: model)
  end
end

# Include the helper in ApplicationController and make methods available to views
Rails.application.config.to_prepare do
  ApplicationController.include RecaptchaHelper
  ApplicationController.helper_method :show_recaptcha?, :verify_recaptcha_if_needed
end 