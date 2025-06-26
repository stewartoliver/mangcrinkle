class SeedInitialContentBlocks < ActiveRecord::Migration[7.1]
  def up
    # About/Founder Section
    ContentBlock.create!(
      key: 'founder_story',
      title: 'Meet Our Founder',
      content: 'Born and raised in Manila, our founder discovered his passion for baking at an early age. His grandmother\'s kitchen was his first classroom, where he learned the art of traditional Filipino baking and the importance of using quality ingredients.

After years of perfecting his craft, he decided to share his love for Filipino-style crinkle cookies with the world. What started as a small home-based business quickly grew into a beloved local brand, known for its authentic flavors and perfect texture.

Today, he continues to personally oversee every batch of cookies, ensuring that each one meets his high standards of quality and taste. His dedication to tradition, combined with a willingness to experiment with new flavors, has made our crinkle cookies a favorite among cookie enthusiasts.',
      description: 'The founder\'s story displayed on the about page and home page',
      content_type: 'text'
    )

    ContentBlock.create!(
      key: 'founder_title',
      title: 'Founder Section Title',
      content: 'Meet Our Founder',
      description: 'The title displayed above the founder story',
      content_type: 'text'
    )

    # Company Values
    ContentBlock.create!(
      key: 'company_values',
      title: 'Our Values',
      content: '[
        {
          "icon": "🌟",
          "title": "Authenticity",
          "description": "We stay true to traditional Filipino baking methods while adding our own unique twist."
        },
        {
          "icon": "❤️",
          "title": "Quality",
          "description": "We use only the finest ingredients, sourced locally whenever possible."
        },
        {
          "icon": "🤝",
          "title": "Community",
          "description": "We believe in supporting our local community and sharing our culture through food."
        }
      ]',
      description: 'Company values displayed on the about page',
      content_type: 'json'
    )

    # Contact Information
    ContentBlock.create!(
      key: 'contact_email',
      title: 'Contact Email',
      content: 'info@mangcrinkle.com',
      description: 'Main contact email address',
      content_type: 'text'
    )

    ContentBlock.create!(
      key: 'contact_phone',
      title: 'Contact Phone',
      content: '(555) 123-4567',
      description: 'Main contact phone number',
      content_type: 'text'
    )

    ContentBlock.create!(
      key: 'contact_address',
      title: 'Contact Address',
      content: '123 Cookie Street
Sweet City, SC 12345',
      description: 'Business address',
      content_type: 'text'
    )

    ContentBlock.create!(
      key: 'business_hours',
      title: 'Business Hours',
      content: 'Monday - Friday: 9:00 AM - 6:00 PM
Saturday: 10:00 AM - 4:00 PM
Sunday: Closed',
      description: 'Business operating hours',
      content_type: 'text'
    )

    # Hero Section Content
    ContentBlock.create!(
      key: 'hero_title',
      title: 'Homepage Hero Title',
      content: 'Mang Crinkle Cookies',
      description: 'Main title on the homepage hero section',
      content_type: 'text'
    )

    ContentBlock.create!(
      key: 'hero_subtitle',
      title: 'Homepage Hero Subtitle',
      content: 'Handcrafted Filipino-style crinkle cookies, baked with love and a touch of kilig! 🤎🇵🇭',
      description: 'Subtitle on the homepage hero section',
      content_type: 'text'
    )

    # Newsletter Section
    ContentBlock.create!(
      key: 'newsletter_title',
      title: 'Newsletter Section Title',
      content: 'Stay Updated',
      description: 'Title for the newsletter signup section',
      content_type: 'text'
    )

    ContentBlock.create!(
      key: 'newsletter_description',
      title: 'Newsletter Description',
      content: 'Subscribe to our newsletter for exclusive offers and new flavor announcements!',
      description: 'Description for the newsletter signup section',
      content_type: 'text'
    )
  end

  def down
    ContentBlock.where(key: [
      'founder_story', 'founder_title', 'company_values', 'contact_email',
      'contact_phone', 'contact_address', 'business_hours', 'hero_title',
      'hero_subtitle', 'newsletter_title', 'newsletter_description'
    ]).destroy_all
  end
end 