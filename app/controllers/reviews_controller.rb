class ReviewsController < ApplicationController
  before_action :set_review, only: [:show]

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
  end

  def create
    @review = Review.new(review_params)
    
    # Associate with current user if logged in
    @review.user = current_user if current_user
    
    # Pre-fill customer info if user is logged in
    if current_user
      @review.customer_name ||= current_user.full_name
      @review.email ||= current_user.email
    end

    if @review.save
      # Send notification to admin (you can implement this later)
      # ReviewMailer.new_review_notification(@review).deliver_later
      
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
    params.require(:review).permit(:customer_name, :email, :rating, :content, :order_id)
  end
end 