class ReviewSpamTracker < ApplicationRecord
  validates :ip_address, presence: true
  validates :email, presence: true
  
  scope :recent, -> { where('created_at > ?', 1.hour.ago) }
  scope :for_ip, ->(ip) { where(ip_address: ip) }
  scope :for_email, ->(email) { where(email: email.downcase.strip) }
  
  def self.rate_limited?(ip_address, email)
    # Check IP rate limiting (max 3 attempts per hour)
    ip_attempts = recent.for_ip(ip_address).count
    return true if ip_attempts >= 3
    
    # Check email rate limiting (max 2 attempts per hour)
    email_attempts = recent.for_email(email).count
    return true if email_attempts >= 2
    
    false
  end
  
  def self.log_attempt(ip_address, email, user_agent = nil)
    create!(
      ip_address: ip_address,
      email: email.downcase.strip,
      user_agent: user_agent,
      attempt_count: 1
    )
  end
  
  def self.cleanup_old_records
    where('created_at < ?', 24.hours.ago).delete_all
  end
end 