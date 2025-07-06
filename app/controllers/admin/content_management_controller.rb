class Admin::ContentManagementController < Admin::BaseController
  def index
    # Group content blocks by purpose for better organization
    @story_content = ContentBlock.where(key: [
      'founder_story', 'founder_image', 'founder_title', 'about_hero_title', 'about_hero_subtitle',
      'hero_title', 'hero_subtitle', 'cta_title', 'cta_subtitle', 'cta_button_text'
    ]).order(:title)
    
    @contact_content = ContentBlock.where(key: [
      'contact_email', 'contact_phone', 'contact_address', 'business_hours'
    ]).order(:title)
    
    @company_values = ContentBlock.where(key: 'company_values').first
    
    @newsletter_content = ContentBlock.where(key: [
      'newsletter_title', 'newsletter_description'
    ]).order(:title)
    
    @all_content_blocks = ContentBlock.all.order(:title)
    
    # Add company information
    @companies = Company.active.ordered
    @main_company = Company.main
  end
end 