module RecaptchaHelper
  def show_recaptcha?
    # Allow reCAPTCHA on admin login for security
    return true if request.path == '/admin/login' || request.path == '/admin/sign_in'
    
    # Don't show reCAPTCHA on other admin routes
    return false if request.path.start_with?('/admin')
    
    # Don't show reCAPTCHA in development/test (handled by gem)
    return false if Rails.env.development? || Rails.env.test?
    
    # Don't show if keys are missing (safety check)
    if ENV['RECAPTCHA_SITE_KEY'].blank? || ENV['RECAPTCHA_SECRET_KEY'].blank?
      Rails.logger.warn "reCAPTCHA keys missing - Site: #{ENV['RECAPTCHA_SITE_KEY'].present?}, Secret: #{ENV['RECAPTCHA_SECRET_KEY'].present?}"
      return false
    end
    
    # Show reCAPTCHA on production with valid keys
    true
  end
  
  def verify_recaptcha_if_needed(model = nil)
    # Allow reCAPTCHA verification on admin login for security
    return true if request.path == '/admin/login' || request.path == '/admin/sign_in'
    
    # Skip reCAPTCHA verification on other admin routes
    return true if request.path.start_with?('/admin')
    
    # Skip verification if reCAPTCHA shouldn't be shown
    return true unless show_recaptcha?
    
    # Use the gem's verification method
    verify_recaptcha(
      action: get_recaptcha_action,
      minimum_score: 0.5
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