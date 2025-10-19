class ReviewNotificationJob < ApplicationJob
  queue_as :default
  
  def perform(review_id)
    review = Review.find(review_id)
    
    ReviewMailer.new_review_notification(review).deliver_now
    Rails.logger.info "Review notification email sent for review #{review_id}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "ReviewNotificationJob failed: Review #{review_id} not found - #{e.message}"
  rescue => e
    Rails.logger.error "ReviewNotificationJob failed: #{e.message}"
    raise e
  end
end
