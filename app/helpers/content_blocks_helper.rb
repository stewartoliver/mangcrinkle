module ContentBlocksHelper
  # Get content block content by key
  def content_block(key)
    ContentBlock.content_for(key)
  end
  
  # Get content block with default fallback
  def content_block_with_default(key, default = '')
    content_block(key) || default
  end
  
  # Render content block as HTML (for HTML content type)
  def render_content_block(key, default = '')
    block = ContentBlock.get(key)
    return default unless block
    
    case block.content_type
    when 'html'
      block.content&.html_safe
    when 'text'
      simple_format(block.content)
    when 'json'
      # For JSON, you might want to render it differently based on your needs
      block.parsed_content
    when 'image'
      if block.image.attached?
        image_tag(block.image, alt: block.title, class: 'img-fluid')
      else
        default
      end
    else
      block.content || default
    end
  end
  
  # Check if content block exists and is active
  def content_block_exists?(key)
    ContentBlock.get(key).present?
  end
  
  # Get content block image
  def content_block_image(key, options = {})
    block = ContentBlock.get(key)
    return nil unless block&.image&.attached?
    
    image_tag(block.image, options.merge(alt: block.title))
  end
  
  # Get content block for editing (admin use)
  def content_block_edit_link(key, text = 'Edit')
    block = ContentBlock.find_by(key: key)
    return unless block && current_user&.admin?
    
    link_to text, edit_admin_content_block_path(block), 
            class: 'btn btn-sm btn-outline-primary',
            target: '_blank'
  end
end 