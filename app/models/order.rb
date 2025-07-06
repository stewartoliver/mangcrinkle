class Order < ApplicationRecord
  belongs_to :user, optional: true
  has_many :line_items, dependent: :destroy
  has_many :order_notes, dependent: :destroy
  has_many :review_invites, dependent: :destroy

  validates :status, presence: true, inclusion: { in: %w[pending processing completed cancelled] }
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :order_source, presence: true, inclusion: { in: %w[website admin_phone admin_email] }
  
  # Customer details validations - either user is present OR legacy fields are filled
  validate :customer_details_present
  validates :customer_name, presence: true, length: { minimum: 2, maximum: 100 }, unless: :user_present?
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, unless: :user_present?
  validates :phone, presence: true, format: { with: /\A\+?\d{10,15}\z/, message: "must be a valid phone number" }, unless: :user_present?
  validates :address, presence: true, length: { minimum: 10, maximum: 500 }, unless: :user_present?

  before_validation :set_default_status, on: :create
  before_validation :set_default_total_price, on: :create
  before_save :sync_customer_details
  after_update :send_review_invite, if: :saved_change_to_status?

  # Scopes for filtering
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_order_source, ->(source) { where(order_source: source) }
  scope :with_customers, -> { includes(:user) }
  scope :by_date_range, ->(start_date, end_date) { where(created_at: start_date.beginning_of_day..end_date.end_of_day) }
  scope :by_customer, ->(customer_name) { where("customer_name ILIKE ?", "%#{customer_name}%") }
  scope :by_email, ->(email) { 
    left_joins(:user).where(
      "LOWER(orders.email) = LOWER(?) OR LOWER(users.email) = LOWER(?)", 
      email.strip, email.strip
    )
  }
  scope :by_email_partial, ->(email) { 
    left_joins(:user).where(
      "orders.email ILIKE ? OR users.email ILIKE ?", 
      "%#{email}%", "%#{email}%"
    )
  }
  scope :by_order_id, ->(order_id) { where(id: order_id) }
  scope :by_min_total, ->(amount) { where("total_price >= ?", amount) }
  scope :by_max_total, ->(amount) { where("total_price <= ?", amount) }

  def total
    total_price
  end

  def customer_name
    user&.full_name || super
  end

  def email
    user&.email || super
  end

  def phone
    user&.phone || super
  end

  def address
    user&.address || super
  end

  def display_name
    "##{id} - #{customer_name} (#{email}) - $#{sprintf('%.2f', total_price)} - #{created_at.strftime('%b %d, %Y')}"
  end

  def status_color
    case status
    when 'pending' then 'yellow'
    when 'processing' then 'blue'
    when 'completed' then 'green'
    when 'cancelled' then 'red'
    else 'gray'
    end
  end

  def add_note(content, admin_user = nil)
    order_notes.create!(
      content: content,
      admin_user: admin_user&.email || 'System'
    )
  end

  def latest_note
    order_notes.order(created_at: :desc).first
  end

  def order_source_display
    case order_source
    when 'website' then 'Website'
    when 'admin_phone' then 'Admin Phone Order'
    when 'admin_email' then 'Admin Email Order'
    else order_source&.titleize
    end
  end

  def calculate_total
    self.total_price = line_items.sum(&:subtotal)
  end

  def recalculate_and_save_total!
    calculate_total
    save! if changed?
  end

  def self.recalculate_all_totals
    find_each do |order|
      order.calculate_total
      order.save! if order.changed?
    end
  end

  def create_review_invite!
    return if review_invites.exists? # Don't create duplicate invites
    
    review_invite = review_invites.build(
      email: email,
      name: customer_name,
      invite_type: 'order',
      admin_notes: "Auto-generated after order completion"
    )
    
    if review_invite.save
      # Send the invitation email with a slight delay to ensure order completion processes finish
      ReviewMailer.review_invite(review_invite).deliver_later(wait: 5.minutes)
      review_invite.update!(sent_at: Time.current)
      Rails.logger.info "Review invite created and sent for Order ##{id}"
    else
      Rails.logger.error "Failed to create review invite for Order ##{id}: #{review_invite.errors.full_messages.join(', ')}"
    end
  end

  private

  def set_default_status
    self.status ||= 'pending'
    self.order_source ||= 'website'
  end

  def set_default_total_price
    self.total_price ||= 0
  end

  def user_present?
    user.present?
  end

  def customer_details_present
    unless user_present? || (customer_name.present? && email.present? && phone.present? && address.present?)
      errors.add(:base, "Either a user must be associated or all customer details must be provided")
    end
  end

  def sync_customer_details
    if user.present?
      # Sync customer details from user if they're not already set
      self.customer_name ||= user.full_name
      self.email ||= user.email
      self.phone ||= user.phone
      self.address ||= user.address
    end
  end

  def send_review_invite
    if status == 'completed' && saved_change_to_status.first != 'completed'
      # Only send if we just changed TO completed status
      create_review_invite!
    end
  end
end
