class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :orders, dependent: :nullify

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :user_type, presence: true, inclusion: { in: %w[admin customer] }
  
  # Password validation only for admin users or when password is being set
  validates :password, length: { minimum: 6 }, if: -> { admin? && (new_record? || !password.nil?) }
  
  # Customer-specific validations
  validates :first_name, presence: true, if: :customer?
  validates :last_name, presence: true, if: :customer?
  validates :phone, presence: true, format: { with: /\A\+?\d{10,15}\z/, message: "must be a valid phone number" }, if: :customer?
  validates :address, presence: true, length: { minimum: 10, maximum: 500 }, if: :customer?

  # Scopes
  scope :customers, -> { where(user_type: 'customer') }
  scope :admins, -> { where(user_type: 'admin') }
  scope :newsletter_subscribers, -> { where(newsletter_subscribed: true) }

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

  # Override Devise's password requirement for customers
  def password_required?
    admin? && super
  end

  # Override Devise's email confirmation requirement for customers
  def email_required?
    admin? && super
  end
end
