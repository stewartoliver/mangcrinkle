class Admin::ReviewsController < Admin::BaseController
  before_action :set_review, only: [:show, :edit, :update, :destroy, :approve, :unapprove, :toggle_featured]

  def index
    @reviews = Review.includes(:user, :order, :approved_by)
    
    case params[:status]
    when 'pending'
      @reviews = @reviews.pending
    when 'approved'
      @reviews = @reviews.approved
    when 'featured'
      @reviews = @reviews.featured
    end
    
    @reviews = @reviews.by_rating(params[:rating]) if params[:rating].present?
    @reviews = @reviews.where('customer_name ILIKE ? OR email ILIKE ? OR content ILIKE ?', 
                              "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
    
    @reviews = @reviews.recent.page(params[:page]).per(20)
    
    # Calculate stats
    @stats = {
      total: Review.count,
      pending: Review.pending.count,
      approved: Review.approved.count,
      featured: Review.featured.count,
      average_rating: Review.approved.average(:rating)&.round(1) || 0
    }
  end

  def show
  end

  def edit
  end

  def update
    if @review.update(review_params)
      redirect_to admin_review_path(@review), notice: 'Review was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @review.destroy
    redirect_to admin_reviews_path, notice: 'Review was successfully deleted.'
  end

  def approve
    @review.approve!(current_user)
    redirect_back(fallback_location: admin_reviews_path, notice: 'Review was approved.')
  end

  def unapprove
    @review.unapprove!
    redirect_back(fallback_location: admin_reviews_path, notice: 'Review was unapproved.')
  end

  def toggle_featured
    if @review.can_be_featured?
      @review.toggle_featured!
      status = @review.featured? ? 'featured' : 'unfeatured'
      redirect_back(fallback_location: admin_reviews_path, notice: "Review was #{status}.")
    else
      redirect_back(fallback_location: admin_reviews_path, alert: 'Only approved reviews can be featured.')
    end
  end

  def bulk_approve
    review_ids = params[:review_ids] || []
    
    if review_ids.empty?
      redirect_back(fallback_location: admin_reviews_path, alert: 'No reviews selected.')
      return
    end

    reviews = Review.where(id: review_ids)
    reviews.each { |review| review.approve!(current_user) }
    redirect_back(fallback_location: admin_reviews_path, notice: "#{reviews.count} reviews were approved.")
  end

  def bulk_unapprove
    review_ids = params[:review_ids] || []
    
    if review_ids.empty?
      redirect_back(fallback_location: admin_reviews_path, alert: 'No reviews selected.')
      return
    end

    reviews = Review.where(id: review_ids)
    reviews.each(&:unapprove!)
    redirect_back(fallback_location: admin_reviews_path, notice: "#{reviews.count} reviews were unapproved.")
  end

  def bulk_feature
    review_ids = params[:review_ids] || []
    
    if review_ids.empty?
      redirect_back(fallback_location: admin_reviews_path, alert: 'No reviews selected.')
      return
    end

    reviews = Review.where(id: review_ids)
    featured_count = 0
    
    reviews.each do |review|
      if review.can_be_featured?
        review.update!(featured: true)
        featured_count += 1
      end
    end
    
    redirect_back(fallback_location: admin_reviews_path, notice: "#{featured_count} reviews were featured.")
  end

  def bulk_unfeature
    review_ids = params[:review_ids] || []
    
    if review_ids.empty?
      redirect_back(fallback_location: admin_reviews_path, alert: 'No reviews selected.')
      return
    end

    reviews = Review.where(id: review_ids)
    reviews.update_all(featured: false)
    redirect_back(fallback_location: admin_reviews_path, notice: "#{reviews.count} reviews were unfeatured.")
  end

  def bulk_destroy
    review_ids = params[:review_ids] || []
    
    if review_ids.empty?
      redirect_back(fallback_location: admin_reviews_path, alert: 'No reviews selected.')
      return
    end

    count = review_ids.count
    Review.where(id: review_ids).destroy_all
    redirect_back(fallback_location: admin_reviews_path, notice: "#{count} reviews were deleted.")
  end

  def bulk_actions
    review_ids = params[:review_ids] || []
    action = params[:bulk_action]
    
    if review_ids.empty?
      redirect_back(fallback_location: admin_reviews_path, alert: 'No reviews selected.')
      return
    end

    reviews = Review.where(id: review_ids)
    
    case action
    when 'approve'
      reviews.each { |review| review.approve!(current_user) }
      redirect_back(fallback_location: admin_reviews_path, notice: "#{reviews.count} reviews were approved.")
    when 'unapprove'
      reviews.each(&:unapprove!)
      redirect_back(fallback_location: admin_reviews_path, notice: "#{reviews.count} reviews were unapproved.")
    when 'delete'
      count = reviews.count
      reviews.destroy_all
      redirect_back(fallback_location: admin_reviews_path, notice: "#{count} reviews were deleted.")
    else
      redirect_back(fallback_location: admin_reviews_path, alert: 'Invalid action selected.')
    end
  end

  private

  def set_review
    @review = Review.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:customer_name, :email, :rating, :content, :admin_notes, :approved, :featured)
  end
end 