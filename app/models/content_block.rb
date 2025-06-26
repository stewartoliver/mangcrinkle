class ContentBlock < ApplicationRecord
  has_one_attached :image
  has_many_attached :images

  validates :key, presence: true, uniqueness: true
  validates :title, presence: true
  validates :content_type, presence: true, inclusion: { in: %w[text html json image] }
  
  scope :by_type, ->(type) { where(content_type: type) }
  scope :ordered, -> { order(:title) }
  scope :by_page, ->(page) { where("page_locations @> ARRAY[?]::text[]", page) }
  
  # Helper method to get content by key (no longer filtering by active)
  def self.get(key)
    find_by(key: key)
  end
  
  # Helper method to get content value by key
  def self.content_for(key)
    block = get(key)
    return nil unless block
    
    # Update last_used_at when content is accessed
    block.touch(:last_used_at) if block.persisted?
    
    case block.content_type
    when 'json'
      JSON.parse(block.content) rescue block.content
    when 'image'
      block.image.attached? ? block.image : nil
    else
      block.content
    end
  end
  
  # Helper method to get parsed JSON content
  def parsed_content
    return content unless content_type == 'json'
    
    JSON.parse(content) rescue content
  end
  
  # Helper method to check if content has an image
  def has_image?
    image.attached? || content_type == 'image'
  end
  
  # Helper method to get display content based on type
  def display_content
    case content_type
    when 'json'
      parsed_content
    when 'image'
      image.attached? ? image : content
    when 'html'
      content&.html_safe
    else
      content
    end
  end
  
  # Helper method for admin display
  def content_preview
    case content_type
    when 'json'
      "JSON Data (#{parsed_content.is_a?(Array) ? parsed_content.length : 'Object'})"
    when 'image'
      image.attached? ? "Image: #{image.filename}" : "No image attached"
    when 'html'
      ActionController::Base.helpers.strip_tags(content).truncate(100)
    else
      content&.truncate(100)
    end
  end
  
  # Helper methods for better UX
  def page_locations_display
    return 'No pages specified' if page_locations.blank?
    page_locations.join(', ')
  end
  
  def preview_available?
    preview_url.present?
  end
  
  # Add page location
  def add_page_location(page_name)
    return if page_locations.include?(page_name)
    self.page_locations = (page_locations + [page_name]).uniq
    save
  end
  
  # Remove page location
  def remove_page_location(page_name)
    self.page_locations = page_locations - [page_name]
    save
  end
end 