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
    when /add_product_cart/, /update_quantity_cart/, /remove_item_cart/, /add_package_cart/
      'cart_action'
    else
      'page_view'
    end
  end
end 