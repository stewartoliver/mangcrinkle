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

  # Test email methods with sample data
  def test_review_invite(test_email)
    @review_invite = OpenStruct.new(
      name: "Test Customer",
      email: test_email,
      token: "test-token-123",
      expires_at: 30.days.from_now
    )
    @order = OpenStruct.new(
      id: 12345,
      total_price: 29.99,
      created_at: 1.week.ago,
      line_items: [
        OpenStruct.new(quantity: 6, purchasable: OpenStruct.new(name: "Classic Chocolate Crinkles")),
        OpenStruct.new(quantity: 3, purchasable: OpenStruct.new(name: "Peanut Butter Crinkles"))
      ]
    )
    @customer_name = @review_invite.name
    @review_url = "https://example.com/reviews/new?token=#{@review_invite.token}"
    
    mail(
      to: test_email,
      subject: "[TEST] Share your experience with Mang Crinkle! 🍪",
      template_name: 'review_invite'
    )
  end

  def test_new_review_notification(test_email)
    @review = OpenStruct.new(
      customer_display_name: "Test Customer",
      email: "customer@example.com",
      rating: 5,
      title: "Amazing cookies!",
      content: "These are absolutely delicious! The texture is perfect and the flavor is incredible. Will definitely order again!",
      verified_purchase?: true,
      created_at: Time.current,
      order: OpenStruct.new(id: 12345)
    )
    
    mail(
      to: test_email,
      subject: "[TEST] New Review Submitted - #{@review.customer_display_name} (#{@review.rating} stars)",
      template_name: 'new_review_notification'
    )
  end
end 