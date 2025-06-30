class Product < ApplicationRecord
  has_many :line_items, as: :purchasable, dependent: :restrict_with_error
  has_many :orders, through: :line_items
  has_many_attached :images  # Only use multiple images - simpler and cleaner

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :short_description, length: { maximum: 255 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :active, inclusion: { in: [true, false] }
  validates :category, presence: true, inclusion: { in: %w[Crinkles Extras Merch] }

  scope :active, -> { where(active: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :crinkles, -> { where(category: 'Crinkles') }
  scope :extras, -> { where(category: 'Extras') }
  scope :merch, -> { where(category: 'Merch') }

  # Helper method to get the primary image
  def primary_image
    return nil unless images.attached?
    
    # If a primary_image_id is set, try to find that specific image
    if primary_image_id.present?
      primary_img = images.find { |img| img.id.to_s == primary_image_id }
      return primary_img if primary_img
    end
    
    # Fallback to first image
    images.first
  end

  # For backward compatibility - return a proxy that behaves like has_one_attached
  def image
    primary_image
  end

  # Helper method to get all images
  def all_images
    images.attached? ? images.to_a : []
  end

  # Helper method to get all images with primary status
  def all_images_with_primary_status
    return [] unless images.attached?
    
    images.map do |img|
      {
        image: img,
        is_primary: primary_image_id.present? ? img.id.to_s == primary_image_id : img == images.first
      }
    end
  end

  # Method to set primary image
  def set_primary_image(image_attachment)
    if images.include?(image_attachment)
      self.primary_image_id = image_attachment.id.to_s
      save
    end
  end

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

  # Method to check if product has any images
  def has_image?
    images.attached? && images.any?
  end

  # Method to get fallback image path
  def fallback_image_path
    'Mang-logo-full-background.jpg'
  end
end
