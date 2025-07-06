class ReviewsController < ApplicationController
  before_action :set_review, only: [:show]
  before_action :check_spam_protection, only: [:create]
  before_action :validate_review_token, only: [:new, :create], if: -> { params[:token].present? }

  def index
    @reviews = Review.approved.recent.includes(:user)
    @reviews = @reviews.by_rating(params[:rating]) if params[:rating].present?
    @reviews = @reviews.page(params[:page]).per(12)
    
    @featured_reviews = Review.featured.limit(3)
    @average_rating = Review.approved.average(:rating)&.round(1) || 0
    @rating_counts = Review.approved.group(:rating).count
    @total_reviews = Review.approved.count
  end

  def show
  end

  def new
    @review = Review.new
    @order = current_user&.orders&.find(params[:order_id]) if params[:order_id]
    @review_invite = @current_review_invite if @current_review_invite
    
    # Pre-fill form data if we have a review invite
    if @review_invite
      @review.customer_name = @review_invite.name
      @review.email = @review_invite.email
      @review.order = @review_invite.order if @review_invite.order
    elsif current_user
      @review.customer_name = current_user.full_name
      @review.email = current_user.email
    end
  end

  def create
    @review = Review.new(review_params)
    @review_invite = @current_review_invite if @current_review_invite
    
    # Associate with current user if logged in
    @review.user = current_user if current_user
    
    # If using a review invite, associate the order and mark invite as used
    if @review_invite
      @review.order = @review_invite.order if @review_invite.order
      @review.customer_name = @review_invite.name
      @review.email = @review_invite.email
    elsif current_user
      # Pre-fill customer info if user is logged in
      @review.customer_name ||= current_user.full_name
      @review.email ||= current_user.email
    end

    # Check honeypot field
    if params[:review][:website].present?
      Rails.logger.warn "Honeypot field filled - potential spam from #{request.remote_ip}"
      redirect_to reviews_path, notice: 'Thank you for your review! It will be published after approval.'
      return
    end

    if @review.save
      # Mark review invite as used
      @review_invite&.use!
      
      # Log the review attempt for spam tracking
      ReviewSpamTracker.log_attempt(
        request.remote_ip,
        @review.email,
        request.user_agent
      )
      
      # Send notification to admin
      ReviewMailer.new_review_notification(@review).deliver_later
      
      redirect_to reviews_path, notice: 'Thank you for your review! It will be published after approval.'
    else
      @order = current_user&.orders&.find(params[:order_id]) if params[:order_id]
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_review
    @review = Review.approved.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:customer_name, :email, :rating, :content, :title, :order_id)
  end

  def validate_review_token
    if params[:token].present?
      @current_review_invite = ReviewInvite.find_by_token(params[:token])
      
      unless @current_review_invite
        redirect_to reviews_path, alert: 'Invalid or expired review invitation link.'
        return
      end
      
      if @current_review_invite.used?
        redirect_to reviews_path, alert: 'This review invitation has already been used.'
        return
      end
      
      if @current_review_invite.expired?
        redirect_to reviews_path, alert: 'This review invitation has expired.'
        return
      end
    end
  end

  def check_spam_protection
    email = params.dig(:review, :email)
    return unless email.present?
    
    if ReviewSpamTracker.rate_limited?(request.remote_ip, email)
      redirect_to reviews_path, alert: 'Too many review attempts. Please try again later.'
      return
    end
  end
end 