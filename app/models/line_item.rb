class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :purchasable, polymorphic: true

  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :purchasable_is_active, on: :create

  serialize :product_quantities, JSON

  before_validation :set_price_from_purchasable, on: :create

  def subtotal
    price * quantity
  end

  def total_price
    subtotal
  end

  def name
    if purchasable.respond_to?(:name)
      purchasable.name
    else
      "Unknown Item"
    end
  end

  def description
    if purchasable.respond_to?(:description)
      purchasable.description
    else
      nil
    end
  end

  def selected_products
    return [] unless purchasable.is_a?(CrinklePackage) && product_quantities.present?
    
    selected_items = []
    product_quantities.each do |product_id, quantity|
      next if quantity.to_i <= 0
      
      product = Product.find_by(id: product_id)
      if product
        selected_items << {
          product: product,
          quantity: quantity.to_i
        }
      end
    end
    
    selected_items
  end

  def selected_products_description
    return nil unless purchasable.is_a?(CrinklePackage) && product_quantities.present?
    
    selected_items = []
    product_quantities.each do |product_id, quantity|
      next if quantity.to_i <= 0
      
      product = Product.find_by(id: product_id)
      if product
        selected_items << "#{quantity}x #{product.name}"
      end
    end
    
    selected_items.join(", ")
  end

  private

  def set_price_from_purchasable
    self.price = purchasable.price if purchasable && price.nil?
  end

  def purchasable_is_active
    if purchasable && purchasable.respond_to?(:active?) && !purchasable.active?
      errors.add(:purchasable, "is not available for purchase")
    end
  end
end
