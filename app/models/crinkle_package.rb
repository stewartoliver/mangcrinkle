class CrinklePackage < ApplicationRecord
  has_one_attached :image
  has_many :line_items, as: :purchasable, dependent: :restrict_with_error
  has_many :orders, through: :line_items
  has_many :package_products, dependent: :destroy, foreign_key: 'package_id'
  has_many :products, through: :package_products

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :active, inclusion: { in: [true, false] }
  validates :holiday_package, inclusion: { in: [true, false] }
  
  # Holiday date validations
  validates :holiday_start_date, presence: true, if: :holiday_package?
  validates :holiday_end_date, presence: true, if: :holiday_package?
  validate :holiday_end_date_after_start_date, if: :holiday_package?

  scope :active, -> { where(active: true) }
  scope :ordered_by_quantity, -> { order(quantity: :asc) }
  scope :holiday_packages, -> { where(holiday_package: true) }
  scope :regular_packages, -> { where(holiday_package: false) }
  scope :currently_available_holiday, -> { 
    holiday_packages.where('holiday_start_date <= ? AND holiday_end_date >= ?', Date.current, Date.current) 
  }
  scope :upcoming_holiday, -> { 
    holiday_packages.where('holiday_start_date > ?', Date.current) 
  }

  def formatted_price
    "$#{format('%.2f', price)}"
  end

  def available_products
    package_products.active.includes(:product)
  end

  def crinkle_products
    package_products.active.crinkles.includes(:product)
  end

  def extra_products
    package_products.active.extras.includes(:product)
  end

  def merch_products
    package_products.active.merch.includes(:product)
  end

  def required_products
    package_products.active.required.includes(:product)
  end

  def optional_products
    package_products.active.optional.includes(:product)
  end

  # Get products grouped by category for the modal
  def products_for_modal
    # If package has configured products, use them
    if package_products.active.any?
      {
        crinkles: crinkle_products.map { |pp| pp.product.as_json(only: [:id, :name, :category], methods: [:primary_image_url]) },
        extras: extra_products.map { |pp| pp.product.as_json(only: [:id, :name, :category], methods: [:primary_image_url]) },
        merch: merch_products.map { |pp| pp.product.as_json(only: [:id, :name, :category], methods: [:primary_image_url]) }
      }
    else
      # Fallback to all active products (old behavior)
      all_products = Product.active
      {
        crinkles: all_products.crinkles.map { |p| p.as_json(only: [:id, :name, :category], methods: [:primary_image_url]) },
        extras: all_products.extras.map { |p| p.as_json(only: [:id, :name, :category], methods: [:primary_image_url]) },
        merch: all_products.merch.map { |p| p.as_json(only: [:id, :name, :category], methods: [:primary_image_url]) }
      }
    end
  end

  def primary_image_url
    image.attached? ? Rails.application.routes.url_helpers.rails_blob_url(image) : nil
  end

  # Holiday package helper methods
  def holiday_active?
    return false unless holiday_package?
    holiday_start_date.present? && holiday_end_date.present? &&
    Date.current >= holiday_start_date && Date.current <= holiday_end_date
  end

  def holiday_upcoming?
    return false unless holiday_package?
    holiday_start_date.present? && holiday_start_date > Date.current
  end

  def holiday_passed?
    return false unless holiday_package?
    holiday_end_date.present? && holiday_end_date < Date.current
  end

  def holiday_status
    return 'regular' unless holiday_package?
    return 'upcoming' if holiday_upcoming?
    return 'active' if holiday_active?
    return 'passed' if holiday_passed?
    'inactive'
  end

  private

  def holiday_end_date_after_start_date
    return unless holiday_start_date.present? && holiday_end_date.present?
    
    if holiday_end_date < holiday_start_date
      errors.add(:holiday_end_date, 'must be after the start date')
    end
  end
end
