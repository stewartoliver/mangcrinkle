class ReviewMailer < ApplicationMailer
  def review_invite(review_invite)
    @review_invite = review_invite
    @order = review_invite.order
    @customer_name = review_invite.name
    @review_url = review_invite.review_url
    
    mail(
      to: review_invite.email,
      subject: "Share your experience with Mang Crinkle! 🍪"
    )
  end
  
  def new_review_notification(review)
    @review = review
    @admin_email = 'admin@mangcrinkle.com' # You can make this configurable
    
    mail(
      to: @admin_email,
      subject: "New Review Submitted - #{review.customer_display_name} (#{review.rating} stars)"
    )
  end
end 