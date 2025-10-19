class ReviewInviteJob < ApplicationJob
  queue_as :default
  
  def perform(review_invite_id)
    review_invite = ReviewInvite.find(review_invite_id)
    
    ReviewMailer.review_invite(review_invite).deliver_now
    Rails.logger.info "Review invite email sent for invite #{review_invite_id}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "ReviewInviteJob failed: ReviewInvite #{review_invite_id} not found - #{e.message}"
  rescue => e
    Rails.logger.error "ReviewInviteJob failed: #{e.message}"
    raise e
  end
end
