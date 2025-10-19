class PackageProduct < ApplicationRecord
  belongs_to :package, class_name: 'CrinklePackage', foreign_key: 'package_id'
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :required, inclusion: { in: [true, false] }
  validates :active, inclusion: { in: [true, false] }
  validates :package_id, uniqueness: { scope: :product_id }

  scope :active, -> { where(active: true) }
  scope :required, -> { where(required: true) }
  scope :optional, -> { where(required: false) }
  scope :by_category, ->(category) { joins(:product).where(products: { category: category }) }
  scope :crinkles, -> { joins(:product).where(products: { category: 'Crinkles' }) }
  scope :extras, -> { joins(:product).where(products: { category: 'Extras' }) }
  scope :merch, -> { joins(:product).where(products: { category: 'Merch' }) }

  def product_name
    product.name
  end

  def product_category
    product.category
  end

  def product_image_url
    product.primary_image ? Rails.application.routes.url_helpers.rails_blob_url(product.primary_image) : nil
  end
end
