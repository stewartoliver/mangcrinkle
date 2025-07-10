class Product < ApplicationRecord
  has_many :line_items, as: :purchasable, dependent: :restrict_with_error
  has_many :orders, through: :line_items
  has_many_attached :images  # Only use multiple images - simpler and cleaner

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :short_description, length: { maximum: 255 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :active, inclusion: { in: [true, false] }
  validates :category, presence: true, inclusion: { in: %w[Crinkles Extras Merch] }
  validates :ingredients, length: { maximum: 2000 }
  validates :allergen_info, length: { maximum: 2000 }
  validates :storage_instructions, length: { maximum: 1000 }

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

  # Helper method to get all images with primary first
  def all_images
    return [] unless images.attached?
    
    images_array = images.to_a
    
    # If no primary image is set, return images in original order
    return images_array unless primary_image_id.present?
    
    # Find the primary image
    primary_img = images_array.find { |img| img.id.to_s == primary_image_id }
    
    # If primary image exists, put it first
    if primary_img
      other_images = images_array.reject { |img| img.id.to_s == primary_image_id }
      [primary_img] + other_images
    else
      # Primary image ID is set but image doesn't exist, clear it and return original order
      update_column(:primary_image_id, nil)
      images_array
    end
  end

  # Helper method to get all images with primary status (for admin interface)
  def all_images_with_primary_status
    return [] unless images.attached?
    
    ordered_images = all_images
    
    ordered_images.map do |img|
      {
        image: img,
        is_primary: primary_image_id.present? ? img.id.to_s == primary_image_id : img == ordered_images.first
      }
    end
  end

  # Ensure we always have a primary image if images exist
  def ensure_primary_image
    Rails.logger.debug "=== ENSURE PRIMARY IMAGE START ===" if Rails.env.development?
    Rails.logger.debug "Images attached: #{images.attached?}" if Rails.env.development?
    Rails.logger.debug "Images count: #{images.attached? ? images.count : 0}" if Rails.env.development?
    Rails.logger.debug "Current primary_image_id: #{primary_image_id}" if Rails.env.development?
    
    if images.attached? && images.any? && primary_image_id.blank?
      first_image_id = images.first.id.to_s
      Rails.logger.debug "Setting primary image to first image: #{first_image_id}" if Rails.env.development?
      
      self.primary_image_id = first_image_id
      if save
        Rails.logger.debug "Successfully set primary image to: #{primary_image_id}" if Rails.env.development?
      else
        Rails.logger.error "Failed to save primary image: #{errors.full_messages}" if Rails.env.development?
      end
    else
      Rails.logger.debug "No need to set primary image" if Rails.env.development?
    end
    
    Rails.logger.debug "=== ENSURE PRIMARY IMAGE END ===" if Rails.env.development?
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
