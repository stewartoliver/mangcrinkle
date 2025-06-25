class Product < ApplicationRecord
  has_many :line_items, as: :purchasable, dependent: :restrict_with_error
  has_many :orders, through: :line_items
  has_one_attached :image

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :active, inclusion: { in: [true, false] }
  validates :category, presence: true, inclusion: { in: %w[Crinkles Extras Merch] }

  scope :active, -> { where(active: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :crinkles, -> { where(category: 'Crinkles') }
  scope :extras, -> { where(category: 'Extras') }
  scope :merch, -> { where(category: 'Merch') }

  def formatted_price
    "$#{format('%.2f', price)}"
  end

  def category_display_name
    case category
    when 'Crinkles'
      'Crinkles'
    when 'Extras'
      'Extras'
    when 'Merch'
      'Merchandise'
    else
      category
    end
  end

  def self.available_categories
    %w[Crinkles Extras Merch]
  end
end
