class ReviewNotificationJob < ApplicationJob
  queue_as :default
  
  def perform(review_id)
    review = Review.find(review_id)
    
    # Use deliver_later for better performance and to avoid blocking the request
    ReviewMailer.new_review_notification(review).deliver_later
    Rails.logger.info "Review notification email queued for review #{review_id}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "ReviewNotificationJob failed: Review #{review_id} not found - #{e.message}"
  rescue => e
    Rails.logger.error "ReviewNotificationJob failed: #{e.message}"
    raise e
  end
end
