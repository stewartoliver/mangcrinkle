class CleanupSpamTrackersJob < ApplicationJob
  queue_as :default

  def perform
    # Clean up spam tracker records older than 24 hours
    deleted_count = ReviewSpamTracker.cleanup_old_records
    Rails.logger.info "Cleaned up #{deleted_count} old spam tracker records"
  end
end 