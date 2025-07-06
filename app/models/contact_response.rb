class ContactResponse < ApplicationRecord
  belongs_to :contact_message

  validates :admin_user, presence: true
  validates :response, presence: true, length: { maximum: 2000 }

  scope :recent, -> { order(created_at: :desc) }

  before_validation :set_sent_at, on: :create

  def admin_name
    # Try to find the admin user by email, fallback to the stored string
    admin = User.admins.find_by(email: admin_user)
    admin&.display_name || admin_user
  end

  private

  def set_sent_at
    self.sent_at ||= Time.current
  end
end
