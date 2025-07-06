class ReviewInvite < ApplicationRecord
  belongs_to :order, optional: true
  
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :name, presence: true
  
  scope :active, -> { where(used_at: nil, expires_at: nil).or(where(used_at: nil).where('expires_at > ?', Time.current)) }
  scope :expired, -> { where('expires_at < ?', Time.current) }
  scope :used, -> { where.not(used_at: nil) }
  
  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create
  
  def active?
    used_at.nil? && (expires_at.nil? || expires_at > Time.current)
  end
  
  def expired?
    expires_at.present? && expires_at < Time.current
  end
  
  def used?
    used_at.present?
  end
  
  def use!
    update!(used_at: Time.current)
  end
  
  def self.find_by_token(token)
    active.find_by(token: token)
  end
  
  def verified_purchase?
    order.present?
  end
  
  def review_url
    Rails.application.routes.url_helpers.new_review_url(token: token)
  end
  
  private
  
  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end
  
  def set_expiration
    # Default to 30 days expiration
    self.expires_at = 30.days.from_now
  end
end 