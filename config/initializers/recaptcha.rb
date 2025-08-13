# Configure reCAPTCHA v3
Recaptcha.configure do |config|
  config.site_key = ENV['RECAPTCHA_SITE_KEY']
  config.secret_key = ENV['RECAPTCHA_SECRET_KEY']
  
  # Disable reCAPTCHA in development and test environments
  if Rails.env.development? || Rails.env.test?
    config.skip_verify_env = ['development', 'test']
  end
end 