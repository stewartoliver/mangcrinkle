class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Virtual attribute for skipping password validation
  attr_accessor :skip_password_validation

  # Associations
  has_many :orders, dependent: :nullify
  has_many :contact_messages, dependent: :destroy
  has_one :admin_notification_preference, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :user_type, presence: true, inclusion: { in: %w[admin customer] }
  
  # Password validation only for admin users or when password is being set
  validates :password, length: { minimum: 6 }, if: -> { admin? && password.present? && !skip_password_validation }
  
  # Customer-specific validations
  validates :first_name, presence: true, if: :customer?
  validates :last_name, presence: true, if: :customer?
  validates :phone, presence: true, format: { with: /\A\+?\d{10,15}\z/, message: "must be a valid phone number" }, if: :customer?
  validates :address, presence: true, length: { minimum: 10, maximum: 500 }, if: :customer?

  # Scopes
  scope :customers, -> { where(user_type: 'customer') }
  scope :admins, -> { where(user_type: 'admin') }
  scope :newsletter_subscribers, -> { where(newsletter_subscribed: true) }
  scope :activated_admins, -> { where(user_type: 'admin').where.not(activated_at: nil) }
  scope :pending_activation, -> { where(user_type: 'admin', activated_at: nil) }

  # Methods
  def admin?
    user_type == 'admin'
  end

  def customer?
    user_type == 'customer'
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def display_name
    full_name.present? ? full_name : email
  end

  def notification_preferences
    return nil unless admin?
    admin_notification_preference || create_admin_notification_preference
  end

  # Admin activation methods
  def activated?
    activated_at.present?
  end

  def pending_activation?
    admin? && !activated?
  end

  def activate!
    self.activated_at = Time.current
    save!
  end

  # Override Devise's password requirement for customers
  def password_required?
    return false if skip_password_validation
    
    if admin?
      # Admin users need password only if they're activated or setting a password
      activated? && (new_record? || password.present? || password_confirmation.present?)
    else
      # Customers don't need passwords
      false
    end
  end

  # Override Devise's email confirmation requirement for customers
  def email_required?
    true
  end
end
