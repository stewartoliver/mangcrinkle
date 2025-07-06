# Scheduled Jobs Configuration
# This initializer sets up recurring jobs for the review system

Rails.application.config.after_initialize do
  # Schedule the cleanup job to run every 24 hours
  # This will clean up old spam tracking records
  if Rails.env.production?
    # In production, you would typically use a proper job scheduler like cron or sidekiq-cron
    # For now, we'll just log that this should be set up
    Rails.logger.info "Review system cleanup job should be scheduled to run daily"
    Rails.logger.info "Run: CleanupSpamTrackersJob.perform_later"
    
    # Example cron job entry for production servers:
    # 0 2 * * * cd /path/to/your/app && bundle exec rails runner "CleanupSpamTrackersJob.perform_later"
  elsif Rails.env.development?
    # In development, you can manually run the cleanup job if needed
    Rails.logger.info "To manually run cleanup job: CleanupSpamTrackersJob.perform_now"
  end
end 