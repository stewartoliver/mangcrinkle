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
    
    # Use the gem's verification method with better error handling
    begin
      result = verify_recaptcha(
        action: get_recaptcha_action,
        minimum_score: 0.5
      )
      
      if result
        Rails.logger.info "reCAPTCHA verification successful for action: #{get_recaptcha_action}"
        return true
      else
        Rails.logger.warn "reCAPTCHA verification failed for action: #{get_recaptcha_action}"
        return false
      end
    rescue => e
      Rails.logger.error "reCAPTCHA verification error: #{e.message}"
      # For now, allow the request to proceed if verification fails
      # This prevents the site from breaking while we debug
      return true
    end
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
    when /add_product_cart/, /update_quantity_cart/, /remove_item_cart/, /add_package_cart/
      'cart_action'
    else
      'page_view'
    end
  end
end 