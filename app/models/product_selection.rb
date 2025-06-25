class ProductSelection < ApplicationRecord
  belongs_to :cart_item
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validate :quantity_within_package_limit

  private

  def quantity_within_package_limit
    return unless cart_item&.purchasable&.is_a?(CrinklePackage)
    
    package = cart_item.purchasable
    if quantity > package.quantity
      errors.add(:quantity, "cannot exceed package limit of #{package.quantity}")
    end
  end
end 