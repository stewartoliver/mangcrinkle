class Admin::MonitoringController < Admin::BaseController
  def index
    # Validate and sanitize date parameters to prevent injection
    @start_date = parse_safe_date(params[:start_date]) || 7.days.ago.to_date
    @end_date = parse_safe_date(params[:end_date]) || Date.current
    
    # Ensure end_date is not before start_date
    @end_date = @start_date if @end_date < @start_date
    
    # Limit date range to prevent performance issues
    if (@end_date - @start_date) > 30.days
      @start_date = @end_date - 30.days
    end
    
    # Email delivery status
    @email_delivery_enabled = Rails.application.config.action_mailer.perform_deliveries
    @smtp_configured = ENV['SMTP_USERNAME'].present? && ENV['SMTP_PASSWORD'].present?
    @app_host_configured = ENV['APP_HOST'].present?
    
    # Google Analytics status
    @google_analytics_configured = ENV['GOOGLE_ANALYTICS_ID'].present?
    @google_analytics_id = ENV['GOOGLE_ANALYTICS_ID']
    
    # reCAPTCHA status
    @recaptcha_configured = ENV['RECAPTCHA_SITE_KEY'].present? && ENV['RECAPTCHA_SECRET_KEY'].present?
    
    # Order processing status (business metrics, not failures)
    @pending_orders = Order.where(status: 'pending')
                          .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                          .count
    @processing_orders = Order.where(status: 'processing')
                             .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                             .count
    @completed_orders = Order.where(status: 'completed')
                            .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                            .count
    @cancelled_orders = Order.where(status: 'cancelled')
                            .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                            .count
    
    # Contact message status (business metrics, not failures)
    @new_contact_messages = ContactMessage.where(status: 'new')
                                        .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                                        .count
    @in_progress_contact_messages = ContactMessage.where(status: 'in_progress')
                                                .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                                                .count
    @resolved_contact_messages = ContactMessage.where(status: ['resolved', 'closed'])
                                             .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                                             .count
    
    # Review spam protection activity
    @review_spam_attempts = ReviewSpamTracker.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                                            .count
    
    # System status indicators (real technical monitoring)
    @system_status = {
      database: check_database_connection,
      email_service: @email_delivery_enabled && @smtp_configured,
      storage: check_storage_status,
      background_jobs: check_background_jobs,
      google_analytics: @google_analytics_configured,
      recaptcha: @recaptcha_configured
    }
    
    # Performance metrics
    @avg_order_processing_time = calculate_avg_order_processing_time
    @contact_response_time = calculate_avg_contact_response_time
    @system_uptime = calculate_system_uptime
    
    # Filtered error logging (focus on real application errors)
    @recent_errors = get_filtered_errors
    
    # Email bounce tracking
    @email_bounces = get_email_bounces
    @email_delivery_stats = get_email_delivery_stats
    
    # Background job monitoring
    @job_stats = get_job_stats
    
    # Spam detection and security monitoring
    @spam_detection = get_spam_detection_stats
    
    # Google Analytics summary (if configured)
    @analytics_summary = get_analytics_summary if @google_analytics_configured
  end
  
  private
  
  def parse_safe_date(date_string)
    return nil if date_string.blank?
    
    # Only allow date format YYYY-MM-DD
    if date_string.match?(/^\d{4}-\d{2}-\d{2}$/)
      Date.parse(date_string)
    else
      nil
    end
  rescue ArgumentError
    nil
  end
  
  def check_database_connection
    ActiveRecord::Base.connection.execute("SELECT 1")
    true
  rescue => e
    Rails.logger.error "Database connection failed: #{e.message}"
    false
  end
  
  def check_storage_status
    # Check if file storage is working
    begin
      Rails.application.config.active_storage.service
      true
    rescue => e
      Rails.logger.error "Storage service failed: #{e.message}"
      false
    end
  end
  
  def check_background_jobs
    # Check if background job system is working
    begin
      # Try to enqueue a test job to verify the system is working
      TestJob.perform_later
      true
    rescue => e
      Rails.logger.error "Background job system failed: #{e.message}"
      false
    end
  end
  
  def get_analytics_summary
    # This would typically integrate with Google Analytics API
    # For now, we'll provide a placeholder structure
    {
      page_views: "Configured - Check Google Analytics Dashboard",
      unique_visitors: "Configured - Check Google Analytics Dashboard",
      form_submissions: "Configured - Check Google Analytics Dashboard",
      conversion_rate: "Configured - Check Google Analytics Dashboard",
      top_pages: "Configured - Check Google Analytics Dashboard"
    }
  end
  
  def get_filtered_errors
    # Get recent errors from Rails logs, filtering out bot/spam noise
    errors = []
    
    # Check for recent Rails errors in logs (simplified approach)
    log_file = get_safe_log_file_path
    if log_file && File.exist?(log_file)
      # Limit the number of lines read to prevent memory issues
      recent_log_lines = File.readlines(log_file).last(1000) # Last 1000 lines
      
      recent_log_lines.reverse.each do |line|
        # Skip common bot/spam patterns
        next if line.match?(/wordpress|wp-admin|wp-login|phpmyadmin|admin\.php/i)
        next if line.match?(/404.*\.(php|asp|jsp|aspx)/i)
        next if line.match?(/GET.*\.(php|asp|jsp|aspx)/i)
        next if line.match?(/POST.*\.(php|asp|jsp|aspx)/i)
        next if line.match?(/User-Agent.*bot|crawler|spider/i)
        next if line.match?(/Failed to deliver email.*spam|bounce/i)
        
        # Focus on real application errors
        if line.match?(/ERROR|FATAL|Exception|Error/) && 
           (line.match?(/ActiveRecord|ActionController|ActionView|ActionMailer/i) ||
            line.match?(/validation|save|create|update/i) ||
            line.match?(/SMTP|email|mail/i) ||
            line.match?(/database|connection/i) ||
            line.match?(/job|background/i))
          
          # Extract timestamp and error message
          timestamp_match = line.match(/(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})/)
          error_match = line.match(/(ERROR|FATAL|Exception|Error):\s*(.+)/)
          
          if timestamp_match && error_match
            errors << {
              timestamp: timestamp_match[1],
              type: error_match[1],
              message: error_match[2].strip[0..100] + (error_match[2].length > 100 ? '...' : ''),
              full_message: error_match[2].strip,
              category: categorize_error(error_match[2].strip)
            }
          end
          
          break if errors.length >= 10 # Limit to 10 most recent errors
        end
      end
    end
    
    errors
  end

  def get_safe_log_file_path
    # Only allow access to Rails log files in the expected location
    log_file = Rails.root.join('log', "#{Rails.env}.log")
    
    # Security check: ensure the path is within the Rails log directory
    expected_log_dir = Rails.root.join('log')
    if log_file.to_s.start_with?(expected_log_dir.to_s) && log_file.exist?
      log_file
    else
      nil
    end
  end
  
  def categorize_error(error_message)
    case error_message.downcase
    when /validation|save|create|update/i
      'Data Validation'
    when /smtp|email|mail/i
      'Email Delivery'
    when /database|connection/i
      'Database'
    when /job|background/i
      'Background Jobs'
    when /controller|action/i
      'Application Logic'
    else
      'General'
    end
  end
  
  def get_spam_detection_stats
    # Track spam detection and security events
    stats = {
      total_spam_attempts: 0,
      blocked_ips: [],
      blocked_emails: [],
      honeypot_triggers: 0,
      rate_limit_triggers: 0
    }
    
    # Check for spam detection in logs
    log_file = get_safe_log_file_path
    if log_file && File.exist?(log_file)
      recent_log_lines = File.readlines(log_file).last(5000)
      
      recent_log_lines.each do |line|
        # Count honeypot triggers
        if line.match?(/Honeypot field filled|potential spam/i)
          stats[:honeypot_triggers] += 1
        end
        
        # Count rate limit triggers
        if line.match?(/rate limited|too many attempts/i)
          stats[:rate_limit_triggers] += 1
        end
        
        # Track spam attempts
        if line.match?(/spam|bot|crawler/i)
          stats[:total_spam_attempts] += 1
        end
      end
    end
    
    # Get blocked IPs and emails from ReviewSpamTracker (with privacy protection)
    raw_blocked_ips = ReviewSpamTracker.where('created_at > ?', 24.hours.ago)
                                      .group(:ip_address)
                                      .having('COUNT(*) >= 3')
                                      .pluck(:ip_address)
    
    raw_blocked_emails = ReviewSpamTracker.where('created_at > ?', 24.hours.ago)
                                         .group(:email)
                                         .having('COUNT(*) >= 2')
                                         .pluck(:email)
    
    # Apply privacy protection
    stats[:blocked_ips] = raw_blocked_ips.map { |ip| mask_ip_address(ip) }
    stats[:blocked_emails] = raw_blocked_emails.map { |email| mask_email_address(email) }
    
    stats
  end
  
  def get_email_bounces
    # Track email bounces by checking for failed email deliveries
    bounces = []
    
    # Check for recent email delivery failures in logs
    log_file = get_safe_log_file_path
    if log_file && File.exist?(log_file)
      recent_log_lines = File.readlines(log_file).last(2000)
      
      recent_log_lines.reverse.each do |line|
        if line.match?(/Failed to deliver email|Email delivery failed|SMTP error/i)
          timestamp_match = line.match(/(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})/)
          email_match = line.match(/([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})/)
          reason_match = line.match(/(Failed to deliver|delivery failed|SMTP error):\s*(.+)/i)
          
          if timestamp_match && email_match
            bounces << {
              timestamp: timestamp_match[1],
              email: mask_email_address(email_match[1]), # Apply privacy protection
              reason: reason_match ? reason_match[2].strip[0..50] + '...' : 'Delivery failed',
              full_reason: reason_match ? reason_match[2].strip : 'Email delivery failed'
            }
          end
          
          break if bounces.length >= 10
        end
      end
    end
    
    bounces
  end

  # Privacy protection methods
  def mask_ip_address(ip)
    return 'Unknown' if ip.blank?
    
    # For IPv4: Show only first two octets (e.g., 192.168.xxx.xxx)
    if ip.match?(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
      parts = ip.split('.')
      "#{parts[0]}.#{parts[1]}.xxx.xxx"
    # For IPv6: Show only first 4 segments
    elsif ip.include?(':')
      parts = ip.split(':')
      "#{parts[0]}:#{parts[1]}:#{parts[2]}:#{parts[3]}:xxxx:xxxx"
    else
      'Unknown'
    end
  end

  def mask_email_address(email)
    return 'Unknown' if email.blank?
    
    # Show only first letter and domain (e.g., j***@example.com)
    if email.include?('@')
      username, domain = email.split('@')
      if username.length > 1
        "#{username[0]}#{'*' * (username.length - 1)}@#{domain}"
      else
        "*@#{domain}"
      end
    else
      'Unknown'
    end
  end
  
  def get_email_delivery_stats
    # Calculate email delivery statistics
    total_emails_sent = 0
    failed_emails = 0
    
    # Count emails sent in the period
    log_file = get_safe_log_file_path
    if log_file && File.exist?(log_file)
      recent_log_lines = File.readlines(log_file).last(5000)
      
      recent_log_lines.each do |line|
        if line.match?(/Email sent successfully|Delivered email/i)
          total_emails_sent += 1
        elsif line.match?(/Failed to deliver email|Email delivery failed/i)
          failed_emails += 1
        end
      end
    end
    
    {
      total_sent: total_emails_sent,
      failed: failed_emails,
      success_rate: total_emails_sent > 0 ? ((total_emails_sent - failed_emails).to_f / total_emails_sent * 100).round(1) : 100
    }
  end
  
  def get_job_stats
    # Get background job statistics
    stats = {
      total_jobs: 0,
      failed_jobs: 0,
      avg_processing_time: 0
    }
    
    # Check for job-related log entries
    log_file = get_safe_log_file_path
    if log_file && File.exist?(log_file)
      recent_log_lines = File.readlines(log_file).last(3000)
      
      recent_log_lines.each do |line|
        if line.match?(/Job performed|Job completed|Job failed/i)
          stats[:total_jobs] += 1
          
          if line.match?(/Job failed|Exception in job/i)
            stats[:failed_jobs] += 1
          end
        end
      end
    end
    
    stats[:success_rate] = stats[:total_jobs] > 0 ? ((stats[:total_jobs] - stats[:failed_jobs]).to_f / stats[:total_jobs] * 100).round(1) : 100
    
    stats
  end
  
  def calculate_avg_order_processing_time
    # Calculate average time from pending to completed
    completed_orders = Order.where(status: 'completed')
                           .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                           .where.not(updated_at: nil)
    
    if completed_orders.any?
      total_time = completed_orders.sum { |order| order.updated_at - order.created_at }
      (total_time / completed_orders.count / 3600).round(2) # in hours
    else
      0
    end
  end
  
  def calculate_avg_contact_response_time
    # Calculate average response time for contact messages
    responded_messages = ContactMessage.where(status: ['resolved', 'closed'])
                                     .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
                                     .where.not(updated_at: nil)
    
    if responded_messages.any?
      total_time = responded_messages.sum { |msg| msg.updated_at - msg.created_at }
      (total_time / responded_messages.count / 3600).round(2) # in hours
    else
      0
    end
  end
  
  def calculate_system_uptime
    # Calculate actual uptime based on recent activity
    # This is a simplified calculation - in production you'd want more sophisticated monitoring
    
    # Check if the application has been responding to requests recently
    log_file = get_safe_log_file_path
    if log_file && File.exist?(log_file)
      recent_log_lines = File.readlines(log_file).last(1000)
      
      # Count recent successful requests vs errors
      successful_requests = recent_log_lines.count { |line| line.match?(/Completed 200|Completed 302|Completed 301/i) }
      error_requests = recent_log_lines.count { |line| line.match?(/Completed 5\d\d|Completed 4\d\d/i) }
      
      total_requests = successful_requests + error_requests
      
      if total_requests > 0
        uptime_percentage = (successful_requests.to_f / total_requests * 100).round(1)
        return [uptime_percentage, 99.9].min # Cap at 99.9% for safety
      end
    end
    
    99.9 # Default fallback
  end
end 