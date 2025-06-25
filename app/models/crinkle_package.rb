class CrinklePackage < ApplicationRecord
  has_one_attached :image
  has_many :line_items, as: :purchasable, dependent: :restrict_with_error
  has_many :orders, through: :line_items

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where(active: true) }

  def formatted_price
    "$#{format('%.2f', price)}"
  end
end
