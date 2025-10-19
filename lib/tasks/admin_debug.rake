namespace :admin do
  desc "Debug admin activation issues"
  task debug_activation: :environment do
    puts "=== Admin Activation Debug ==="
    
    # Check all admin users
    admin_users = User.where(user_type: 'admin')
    puts "Total admin users: #{admin_users.count}"
    
    admin_users.each do |user|
      puts "\n--- User ID: #{user.id} ---"
      puts "Email: #{user.email}"
      puts "User Type: #{user.user_type}"
      puts "Activated: #{user.activated?}"
      puts "Activated At: #{user.activated_at}"
      puts "Has Password: #{user.encrypted_password.present?}"
      puts "Reset Token: #{user.reset_password_token.present? ? 'Present' : 'None'}"
      puts "Reset Token Sent At: #{user.reset_password_sent_at}"
      puts "Activation Status: #{user.activation_status}"
      
      if user.reset_password_token.present?
        # Check if token is expired
        if user.reset_password_sent_at && user.reset_password_sent_at < 6.hours.ago
          puts "⚠️  Reset token is EXPIRED (older than 6 hours)"
        else
          puts "✅ Reset token is valid"
        end
      end
    end
    
    puts "\n=== Devise Configuration ==="
    puts "Reset password within: #{Devise.reset_password_within}"
    puts "Sign in after reset password: #{Devise.sign_in_after_reset_password}"
    
    puts "\n=== Routes Check ==="
    puts "Password edit route: #{Rails.application.routes.url_helpers.edit_user_password_path}"
  end
  
  desc "Test admin activation email generation"
  task test_activation_email: :environment do
    puts "=== Testing Admin Activation Email ==="
    
    # Find a pending admin user
    admin_user = User.where(user_type: 'admin', activated_at: nil).first
    
    if admin_user
      puts "Testing with user: #{admin_user.email}"
      
      begin
        # Generate activation email
        AdminMailer.admin_activation(admin_user).deliver_now
        puts "✅ Activation email sent successfully"
        
        # Check the user's reset token
        admin_user.reload
        puts "Reset token generated: #{admin_user.reset_password_token.present?}"
        puts "Reset token sent at: #{admin_user.reset_password_sent_at}"
        
        # Generate the URL
        raw_token = admin_user.reset_password_token
        url = Rails.application.routes.url_helpers.edit_user_password_url(reset_password_token: raw_token)
        puts "Generated URL: #{url}"
        
      rescue => e
        puts "❌ Error sending activation email: #{e.message}"
        puts e.backtrace.first(5).join("\n")
      end
    else
      puts "No pending admin users found"
    end
  end
  
  desc "Test error page behavior for different user types"
  task test_error_pages: :environment do
    puts "=== Testing Error Page Behavior ==="
    
    # Test with no user
    puts "\n--- No User Signed In ---"
    puts "Expected: Customer error page"
    
    # Test with customer user
    customer = User.where(user_type: 'customer').first
    if customer
      puts "\n--- Customer User (#{customer.email}) ---"
      puts "User Type: #{customer.user_type}"
      puts "Activated: #{customer.activated?}"
      puts "Expected: Customer error page"
    else
      puts "\nNo customer users found"
    end
    
    # Test with admin user (not activated)
    pending_admin = User.where(user_type: 'admin', activated_at: nil).first
    if pending_admin
      puts "\n--- Pending Admin User (#{pending_admin.email}) ---"
      puts "User Type: #{pending_admin.user_type}"
      puts "Activated: #{pending_admin.activated?}"
      puts "Expected: Customer error page (not activated)"
    else
      puts "\nNo pending admin users found"
    end
    
    # Test with activated admin user
    activated_admin = User.where(user_type: 'admin').where.not(activated_at: nil).first
    if activated_admin
      puts "\n--- Activated Admin User (#{activated_admin.email}) ---"
      puts "User Type: #{activated_admin.user_type}"
      puts "Activated: #{activated_admin.activated?}"
      puts "Activated At: #{activated_admin.activated_at}"
      puts "Expected: Admin error page"
    else
      puts "\nNo activated admin users found"
    end
    
    puts "\n=== Test URLs ==="
    puts "404 Error: /test-404"
    puts "500 Error: /test-500"
    puts "Direct 404: /404"
    puts "Direct 500: /500"
  end
end
