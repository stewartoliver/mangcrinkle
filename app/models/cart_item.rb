class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product, optional: true
  belongs_to :crinkle_package, optional: true

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validate :has_product_or_package

  serialize :product_quantities, coder: JSON

  def subtotal
    if product.present?
      (product.price || 0) * quantity
    elsif crinkle_package.present?
      (crinkle_package.price || 0) * quantity
    else
      0
    end
  end

  def name
    if product.present?
      product.name
    elsif crinkle_package.present?
      crinkle_package.name
    else
      "Unknown Item"
    end
  end

  def description
    if product.present?
      product.description
    elsif crinkle_package.present?
      crinkle_package.description
    else
      nil
    end
  end

  def price
    if product.present?
      product.price
    elsif crinkle_package.present?
      crinkle_package.price
    else
      0
    end
  end

  def selected_products
    return [] unless crinkle_package.present? && product_quantities.present?
    
    # Get all product IDs at once to avoid N+1 queries
    product_ids = product_quantities.keys.map(&:to_i).select { |id| id > 0 }
    products = Product.where(id: product_ids).index_by(&:id)
    
    selected_items = []
    product_quantities.each do |product_id, quantity|
      next if quantity.to_i <= 0
      
      product = products[product_id.to_i]
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
    return nil unless crinkle_package.present? && product_quantities.present?
    
    # Get all product IDs at once to avoid N+1 queries
    product_ids = product_quantities.keys.map(&:to_i).select { |id| id > 0 }
    products = Product.where(id: product_ids).index_by(&:id)
    
    selected_items = []
    product_quantities.each do |product_id, quantity|
      next if quantity.to_i <= 0
      
      product = products[product_id.to_i]
      if product
        selected_items << "#{quantity}x #{product.name}"
      end
    end
    
    selected_items.join(", ")
  end

  private

  def has_product_or_package
    unless product.present? || crinkle_package.present?
      errors.add(:base, "Cart item must have either a product or a package")
    end
  end
end 