class ReviewConfirmationJob < ApplicationJob
  queue_as :default
  
  def perform(review_id)
    review = Review.find(review_id)
    
    ReviewMailer.review_confirmation(review).deliver_now
    Rails.logger.info "Review confirmation email sent for review #{review_id}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "ReviewConfirmationJob failed: Review #{review_id} not found - #{e.message}"
  rescue => e
    Rails.logger.error "ReviewConfirmationJob failed: #{e.message}"
    raise e
  end
end
