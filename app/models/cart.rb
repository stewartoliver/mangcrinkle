class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  has_many :crinkle_packages, through: :cart_items

  def add_product(product, quantity = 1)
    cart_item = cart_items.find_or_initialize_by(product: product)
    cart_item.quantity = (cart_item.quantity || 0) + quantity
    cart_item.save
  end

  def add_package(package, product_quantities)
    return false unless valid_package_selection?(package, product_quantities)

    ActiveRecord::Base.transaction do
      # Create a cart item for the package itself with the selected product quantities
      cart_items.create!(
        crinkle_package: package,
        quantity: 1,
        product_quantities: product_quantities
      )
    end
    true
  rescue ActiveRecord::RecordNotFound
    false
  end

  def update_quantity(product, quantity)
    cart_item = cart_items.find_by(product: product)
    return false unless cart_item

    if quantity > 0
      cart_item.update(quantity: quantity)
    else
      cart_item.destroy
    end
  end

  def remove_product(product)
    cart_items.where(product: product).destroy_all
  end

  def total_price
    cart_items.sum { |item| item.subtotal || 0 }
  end

  def empty?
    cart_items.empty?
  end

  def clear
    cart_items.destroy_all
  end

  private

  def valid_package_selection?(package, product_quantities)
    total_quantity = product_quantities.values.sum(&:to_i)
    total_quantity > 0 && total_quantity <= package.quantity
  end
end 