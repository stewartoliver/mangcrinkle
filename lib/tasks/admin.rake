namespace :admin do
  desc "Create admin user"
  task create_user: :environment do
    admin_email = ENV['ADMIN_EMAIL'] || 'oliverstewart35@gmail.com'
    admin_password = ENV['ADMIN_PASSWORD'] || 'defaultpassword123'
    
    puts "Creating admin user with email: #{admin_email}"
    
    # Remove existing admin user if it exists
    existing_user = User.find_by(email: admin_email)
    if existing_user
      puts "Removing existing user: #{admin_email}"
      existing_user.destroy
    end
    
    # Create new admin user
    admin_user = User.create!(
      email: admin_email,
      user_type: 'admin',
      first_name: 'Oliver',
      last_name: 'Stewart',
      password: admin_password,
      password_confirmation: admin_password
    )
    
    puts "✅ Admin user created successfully!"
    puts "Email: #{admin_user.email}"
    puts "Password: #{admin_password}"
    puts "You can now log in to the admin panel."
    
  rescue => e
    puts "❌ Error creating admin user: #{e.message}"
    puts "Full error: #{e.backtrace.first(5).join("\n")}"
  end
end 