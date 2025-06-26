class UpdateContentBlocksForBetterUx < ActiveRecord::Migration[7.0]
  def up
    # Add page location tracking
    add_column :content_blocks, :page_locations, :text, array: true, default: []
    add_column :content_blocks, :usage_context, :text
    add_column :content_blocks, :last_used_at, :datetime
    
    # Add preview URL for better admin experience
    add_column :content_blocks, :preview_url, :string
    
    # Remove the confusing active boolean - we'll handle this differently
    remove_column :content_blocks, :active, :boolean
    
    # Update existing content blocks with page location data
    # Based on the current usage in about.html.erb
    about_page_blocks = [
      'about_hero_title',
      'about_hero_subtitle', 
      'founder_image',
      'founder_section_title',
      'founder_story',
      'values_section_title',
      'value_1_icon',
      'value_1_title', 
      'value_1_description',
      'value_2_icon',
      'value_2_title',
      'value_2_description', 
      'value_3_icon',
      'value_3_title',
      'value_3_description',
      'cta_title',
      'cta_subtitle',
      'cta_button_text'
    ]
    
    about_page_blocks.each do |key|
      block = ContentBlock.find_by(key: key)
      if block
        block.update!(
          page_locations: ['About Page'],
          preview_url: '/about',
          usage_context: get_usage_context(key)
        )
      end
    end
  end
  
  def down
    remove_column :content_blocks, :page_locations
    remove_column :content_blocks, :usage_context
    remove_column :content_blocks, :last_used_at
    remove_column :content_blocks, :preview_url
    
    add_column :content_blocks, :active, :boolean, default: true
  end
  
  private
  
  def get_usage_context(key)
    contexts = {
      'about_hero_title' => 'Main heading displayed at the top of the About page',
      'about_hero_subtitle' => 'Subtitle text below the main heading on the About page',
      'founder_image' => 'Photo of the founder displayed in the founder section',
      'founder_section_title' => 'Heading for the founder story section',
      'founder_story' => 'Main story content about the founder (supports HTML formatting)',
      'values_section_title' => 'Heading for the company values section',
      'value_1_icon' => 'Icon/emoji for the first company value',
      'value_1_title' => 'Title of the first company value',
      'value_1_description' => 'Description of the first company value',
      'value_2_icon' => 'Icon/emoji for the second company value',
      'value_2_title' => 'Title of the second company value',
      'value_2_description' => 'Description of the second company value',
      'value_3_icon' => 'Icon/emoji for the third company value',
      'value_3_title' => 'Title of the third company value', 
      'value_3_description' => 'Description of the third company value',
      'cta_title' => 'Call-to-action heading at the bottom of the page',
      'cta_subtitle' => 'Call-to-action subtitle text',
      'cta_button_text' => 'Text displayed on the call-to-action button'
    }
    
    contexts[key] || 'Content block usage context'
  end
end 