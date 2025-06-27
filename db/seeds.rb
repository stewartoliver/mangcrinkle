# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "🌱 Starting database seeding..."

# Clean up existing content blocks to ensure only our two remain
puts "🧹 Cleaning up existing content blocks..."
ContentBlock.destroy_all

# Create only the essential content blocks
puts "📝 Creating essential content blocks..."

# Founder Story Content Block
founder_story = ContentBlock.find_or_create_by(key: 'founder_story') do |cb|
  cb.title = 'Founder Story'
  cb.content = 'Born and raised in Manila, our founder discovered his passion for baking at an early age. His grandmother\'s kitchen was his first classroom, where he learned the art of traditional Filipino baking and the importance of using quality ingredients.

After years of perfecting his craft, he decided to share his love for Filipino-style crinkle cookies with the world. What started as a small home-based business quickly grew into a beloved local brand, known for its authentic flavors and perfect texture.

Today, he continues to personally oversee every batch of cookies, ensuring that each one meets his high standards of quality and taste. His dedication to tradition, combined with a willingness to experiment with new flavors, has made our crinkle cookies a favorite among cookie enthusiasts.'
  cb.content_type = 'text'
end

if founder_story.persisted?
  puts "✅ Created content block: Founder Story"
else
  puts "❌ Failed to create founder story: #{founder_story.errors.full_messages.join(', ')}"
end

# Company Values Content Block
company_values = ContentBlock.find_or_create_by(key: 'company_values') do |cb|
  cb.title = 'Our Values'
  cb.content = '[
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
  ]'
  cb.content_type = 'json'
end

if company_values.persisted?
  puts "✅ Created content block: Company Values"
else
  puts "❌ Failed to create company values: #{company_values.errors.full_messages.join(', ')}"
end

# Create main company details
puts "🏢 Creating company information..."

# Clean up existing companies first (optional - remove if you want to keep existing)
Company.destroy_all

# Create the main company with details from the front-facing website
main_company = Company.find_or_create_by(name: 'Mang Crinkle Cookies') do |company|
  company.email = 'info@mangcrinkle.com'
  company.phone = '(555) 123-4567'
  company.website = 'https://mangcrinkle.com'
  company.address = '123 Cookie Street
Sweet City, SC 12345'
  company.description = 'Artisanal Filipino-style crinkle cookies, baked with love and a touch of kilig! From traditional flavors like Ube to modern favorites like Matcha and Espresso, each batch is handcrafted with premium ingredients and authentic baking methods passed down through generations.'
  company.business_hours = {
    "monday" => "9:00 AM - 6:00 PM",
    "tuesday" => "9:00 AM - 6:00 PM", 
    "wednesday" => "9:00 AM - 6:00 PM",
    "thursday" => "9:00 AM - 6:00 PM",
    "friday" => "9:00 AM - 6:00 PM",
    "saturday" => "10:00 AM - 4:00 PM",
    "sunday" => "Closed"
  }
  company.active = true
end

if main_company.persisted?
  puts "✅ Created main company: #{main_company.name}"
else
  puts "❌ Failed to create main company: #{main_company.errors.full_messages.join(', ')}"
end

# Create admin user
admin_email = ENV['ADMIN_EMAIL'] || 'oliverstewart35@gmail.com'
admin_password = ENV['ADMIN_PASSWORD'] || '0J4VASCRIPTSK1LL!'

puts "🔐 Creating admin user..."
puts "   Email: #{admin_email}"

# Always try to create the admin user
admin_user = User.find_or_initialize_by(email: admin_email)
admin_user.user_type = 'admin'
admin_user.first_name = 'Oliver'
admin_user.last_name = 'Stewart'
admin_user.password = admin_password
admin_user.password_confirmation = admin_password

if admin_user.save
  puts "✅ Admin user created/updated: #{admin_email}"
  puts "   Password: #{admin_password}"
else
  puts "❌ Failed to create admin user: #{admin_user.errors.full_messages.join(', ')}"
  puts "   Trying alternative approach..."
  
  # Alternative approach - destroy and recreate
  existing = User.find_by(email: admin_email)
  existing&.destroy
  
  admin_user = User.create!(
    email: admin_email,
    user_type: 'admin',
    first_name: 'Oliver',
    last_name: 'Stewart',
    password: admin_password,
    password_confirmation: admin_password
  )
  puts "✅ Admin user created with alternative approach: #{admin_email}"
end

# Create sample products
puts "📦 Creating sample products..."

# Crinkles Category
crinkle_products = [
  {
    name: "Chocolate Crinkle",
    description: "Our signature chocolate crinkle cookie with a perfect crackled top and rich chocolate flavor. Made with premium cocoa and dusted with powdered sugar for that classic Filipino bakery taste.",
    price: 3.50,
    category: "Crinkles",
    active: true
  },
  {
    name: "Ube Crinkle",
    description: "Our signature Filipino purple yam flavor, rich and naturally sweet.",
    price: 3.50,
    category: "Crinkles",
    active: true
  },
  {
    name: "Espresso Crinkle",
    description: "Rich coffee flavor with a perfect crinkle texture.",
    price: 3.50,
    category: "Crinkles",
    active: true
  },
  {
    name: "Red Velvet Crinkle",
    description: "A modern twist on the classic crinkle! Rich red velvet flavor with cream cheese undertones, topped with a generous dusting of powdered sugar.",
    price: 3.50,
    category: "Crinkles",
    active: true
  },
  {
    name: "Matcha Crinkle",
    description: "Premium Japanese matcha powder gives this crinkle its vibrant green color and distinctive earthy flavor. Perfect for tea lovers!",
    price: 3.50,
    category: "Crinkles",
    active: true
  },
  {
    name: "Chocolate Mint Crinkle",
    description: "Minty and Chocolatey perfection! Rich chocolate flavor with a sweet hit of mint, creating a sophisticated taste that's hard to resist.",
    price: 3.50,
    category: "Crinkles",
    active: true
  }
]

# Create all products
all_products = crinkle_products

all_products.each do |product_attrs|
  product = Product.find_or_create_by(name: product_attrs[:name]) do |p|
    p.description = product_attrs[:description]
    p.price = product_attrs[:price]
    p.category = product_attrs[:category]
    p.active = product_attrs[:active]
  end
  
  if product.persisted?
    puts "✅ Created product: #{product.name}"
  else
    puts "❌ Failed to create product #{product_attrs[:name]}: #{product.errors.full_messages.join(', ')}"
  end
end

# Create crinkle packages
puts "📦 Creating crinkle packages..."

package_data = [
  {
    name: "Single",
    description: "1 Crinkle Cookie",
    price: 3.50,
    quantity: 1,
    active: true
  },
  {
    name: "3 Pack",
    description: "Perfect for sharing",
    price: 9.00,
    quantity: 3,
    active: true
  },
  {
    name: "6 Pack",
    description: "Family Size",
    price: 17.00,
    quantity: 6,
    active: true
  },
  {
    name: "12 Pack",
    description: "Party Size",
    price: 31.00,
    quantity: 12,
    active: true
  }
]

package_data.each do |package_attrs|
  package = CrinklePackage.find_or_create_by(name: package_attrs[:name]) do |p|
    p.description = package_attrs[:description]
    p.price = package_attrs[:price]
    p.quantity = package_attrs[:quantity]
    p.active = package_attrs[:active]
  end
  
  if package.persisted?
    puts "✅ Created package: #{package.name}"
  else
    puts "❌ Failed to create package #{package_attrs[:name]}: #{package.errors.full_messages.join(', ')}"
  end
end

# Create sample customer users (for testing)
puts "👥 Creating sample customer users..."

sample_customers = [
  {
    email: "maria.santos@example.com",
    first_name: "Maria",
    last_name: "Santos",
    phone: "555-0101",
    address: "123 Filipino Street, San Francisco, CA 94102",
    newsletter_subscribed: true
  },
  {
    email: "juan.delacruz@example.com",
    first_name: "Juan",
    last_name: "Dela Cruz",
    phone: "555-0102",
    address: "456 Bay Area Blvd, Oakland, CA 94601",
    newsletter_subscribed: false
  },
  {
    email: "ana.garcia@example.com",
    first_name: "Ana",
    last_name: "Garcia",
    phone: "555-0103",
    address: "789 Pacific Ave, San Jose, CA 95110",
    newsletter_subscribed: true
  }
]

sample_customers.each do |customer_attrs|
  user = User.find_or_create_by(email: customer_attrs[:email]) do |u|
    u.first_name = customer_attrs[:first_name]
    u.last_name = customer_attrs[:last_name]
    u.phone = customer_attrs[:phone]
    u.address = customer_attrs[:address]
    u.newsletter_subscribed = customer_attrs[:newsletter_subscribed]
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  
  if user.persisted?
    puts "✅ Created customer: #{user.first_name} #{user.last_name}"
  else
    puts "❌ Failed to create customer #{customer_attrs[:email]}: #{user.errors.full_messages.join(', ')}"
  end
end

# Create sample orders (for testing)
puts "📋 Creating sample orders..."

# Get some products and packages for sample orders
sample_products = Product.active.limit(3)
sample_packages = CrinklePackage.active.limit(2)
sample_users = User.where(user_type: 'customer').limit(2)

if sample_products.any? && sample_packages.any? && sample_users.any?
  # Sample Order 1 - Individual products
  order1 = Order.create!(
    customer_name: "Maria Santos",
    email: "maria.santos@example.com",
    phone: "555-0101",
    address: "123 Filipino Street, San Francisco, CA 94102",
    status: "delivered",
    total_price: 21.00,
    user: sample_users.first,
    order_source: "website",
    shipped_at: 1.week.ago,
    delivered_at: 1.week.ago + 3.days,
    tracking_number: "1Z999AA1234567890",
    shipping_carrier: "UPS"
  )
  
  # Add line items for order 1 (3 products × 2 each = $21.00)
  sample_products.first(3).each do |product|
    LineItem.create!(
      order: order1,
      purchasable: product,
      quantity: 2,
      price: product.price
    )
  end
  
  puts "✅ Created sample order: #{order1.customer_name} - $#{order1.total_price}"
  
  # Sample Order 2 - Package with product selections
  order2 = Order.create!(
    customer_name: "Juan Dela Cruz",
    email: "juan.delacruz@example.com",
    phone: "555-0102",
    address: "456 Bay Area Blvd, Oakland, CA 94601",
    status: "shipped",
    total_price: 17.00,
    user: sample_users.last,
    order_source: "website",
    shipped_at: 2.days.ago,
    tracking_number: "1Z999AA1234567891",
    shipping_carrier: "UPS"
  )
  
  # Add 6 Pack with product selections
  six_pack = CrinklePackage.find_by(name: "6 Pack")
  if six_pack
    LineItem.create!(
      order: order2,
      purchasable: six_pack,
      quantity: 1,
      price: six_pack.price,
      product_quantities: {
        sample_products.first.id.to_s => 2,
        sample_products.second.id.to_s => 2,
        sample_products.third.id.to_s => 2
      }
    )
  end
  
  puts "✅ Created sample order: #{order2.customer_name} - $#{order2.total_price}"
  
  # Sample Order 3 - Pending order
  order3 = Order.create!(
    customer_name: "Ana Garcia",
    email: "ana.garcia@example.com",
    phone: "555-0103",
    address: "789 Pacific Ave, San Jose, CA 95110",
    status: "pending",
    total_price: 31.00,
    user: sample_users.first,
    order_source: "website"
  )
  
  # Add 12 Pack
  twelve_pack = CrinklePackage.find_by(name: "12 Pack")
  if twelve_pack
    LineItem.create!(
      order: order3,
      purchasable: twelve_pack,
      quantity: 1,
      price: twelve_pack.price,
      product_quantities: {
        sample_products.first.id.to_s => 4,
        sample_products.second.id.to_s => 4,
        sample_products.third.id.to_s => 4
      }
    )
  end
  
  puts "✅ Created sample order: #{order3.customer_name} - $#{order3.total_price}"
  
  # Add some order notes
  OrderNote.create!(
    order: order1,
    content: "Customer requested extra packaging for gift. Added tissue paper and ribbon.",
    admin_user: "Oliver Stewart"
  )
  
  OrderNote.create!(
    order: order2,
    content: "Customer called to confirm delivery address. All good to proceed.",
    admin_user: "Oliver Stewart"
  )
  
  puts "✅ Created sample order notes"
else
  puts "⚠️  Skipping sample orders - not enough products, packages, or users created"
end

puts "🌱 Database seeding completed!"
puts ""
puts "📊 Summary:"
puts "   • #{ContentBlock.count} content blocks created (founder_story, company_values)"
puts "   • #{Company.count} company created"
puts "   • #{Product.count} products created"
puts "   • #{CrinklePackage.count} packages created"
puts "   • #{User.count} users created"
puts "   • #{Order.count} orders created"
puts ""
puts "🎉 Your Mang Crinkle database is ready for deployment!"
