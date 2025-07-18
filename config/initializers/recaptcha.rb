# Configure reCAPTCHA v3
Recaptcha.configure do |config|
  config.site_key = ENV['RECAPTCHA_SITE_KEY']
  config.secret_key = ENV['RECAPTCHA_SECRET_KEY']
  
  # Disable reCAPTCHA in development and test environments
  if Rails.env.development? || Rails.env.test?
    config.skip_verify_env = ['development', 'test']
  end
end

# Helper methods for reCAPTCHA v3
module RecaptchaHelper
  def show_recaptcha?
    # TEMPORARILY DISABLED FOR TESTING
    return false
    
    # Don't show reCAPTCHA in admin routes
    return false if request.path.start_with?('/admin')
    
    # Don't show reCAPTCHA in development/test
    return false if Rails.env.development? || Rails.env.test?
    
    # Don't show on localhost
    return false if request.host.include?('localhost') || request.host.include?('127.0.0.1')
    
    # Don't show if keys are missing (safety check)
    return false if ENV['RECAPTCHA_SITE_KEY'].blank? || ENV['RECAPTCHA_SECRET_KEY'].blank?
    
    # Show reCAPTCHA on production with valid keys
    true
  end
  
  def verify_recaptcha_if_needed(model = nil)
    # Skip reCAPTCHA verification in admin routes
    return true if request.path.start_with?('/admin')
    
    # Skip verification if reCAPTCHA shouldn't be shown
    return true unless show_recaptcha?
    
    # For reCAPTCHA v3, use the standard verification method
    # The gem should automatically detect v3 keys and handle them properly
    verify_recaptcha(
      model: model,
      action: get_recaptcha_action
    )
  end
  
  private
  
  def get_recaptcha_action
    # Different actions for different forms
    case request.path
    when /contact/
      'contact_form'
    when /orders/
      'order_form'
    when /reviews/
      'review_form'
    when /newsletter/
      'newsletter_subscription'
    else
      'page_view'
    end
  end
end

# Include helpers in ApplicationController
Rails.application.config.to_prepare do
  ApplicationController.include RecaptchaHelper
  ApplicationController.helper_method :show_recaptcha?, :verify_recaptcha_if_needed
end 