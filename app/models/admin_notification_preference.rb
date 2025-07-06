class AdminNotificationPreference < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validate :user_must_be_admin

  before_validation :set_defaults, on: :create

  def self.for_admin(admin_user)
    find_or_create_by(user: admin_user)
  end

  def notification_types
    types = []
    types << 'New Orders' if new_order_notifications?
    types << 'Weekly Sales Report' if weekly_sales_report?
    types << 'Monthly Sales Report' if monthly_sales_report?
    types << 'Contact Form Messages' if contact_form_notifications?
    types
  end

  private

  def user_must_be_admin
    errors.add(:user, 'must be an admin') unless user&.admin?
  end

  def set_defaults
    self.new_order_notifications = true if new_order_notifications.nil?
    self.weekly_sales_report = true if weekly_sales_report.nil?
    self.monthly_sales_report = true if monthly_sales_report.nil?
    self.contact_form_notifications = true if contact_form_notifications.nil?
  end
end
