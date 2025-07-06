class Review < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :order, optional: true
  belongs_to :approved_by, class_name: 'User', optional: true
  has_many :review_invites, through: :order

  validates :customer_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :content, presence: true, length: { minimum: 10, maximum: 500 }
  validates :title, length: { maximum: 100 }, allow_blank: true

  scope :approved, -> { where(approved: true) }
  scope :pending, -> { where(approved: false) }
  scope :featured, -> { where(featured: true, approved: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_rating, ->(rating) { where(rating: rating) }
  scope :high_rated, -> { where(rating: 4..5) }

  before_save :set_approved_at, if: :approved_changed?

  def approve!(admin_user)
    update!(approved: true, approved_by: admin_user, approved_at: Time.current)
  end

  def unapprove!
    update!(approved: false, approved_by: nil, approved_at: nil)
  end

  def toggle_featured!
    update!(featured: !featured?)
  end

  def can_be_featured?
    approved?
  end

  def customer_display_name
    if user.present?
      user.full_name.present? ? user.full_name : user.email.split('@').first.capitalize
    else
      customer_name
    end
  end

  def star_display
    '★' * rating + '☆' * (5 - rating)
  end

  def recent?
    created_at > 1.week.ago
  end

  def parsed_content
    # For future use if you want to parse content differently
    content
  end

  def verified_purchase?
    order.present?
  end

  def display_title
    title.present? ? title : "#{rating}-star review"
  end

  private

  def set_approved_at
    if approved?
      self.approved_at = Time.current
    else
      self.approved_at = nil
    end
  end
end 