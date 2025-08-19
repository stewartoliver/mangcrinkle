class Admin::ReviewsController < Admin::BaseController
  before_action :set_review, only: [:show, :edit, :update, :destroy, :approve, :unapprove, :toggle_featured]

  def index
    @reviews = Review.includes(:user, :order, :approved_by)
    
    # Store current tab for view - use status parameter from tabs, fallback to all
    @current_tab = params[:status] || 'all'
    
    case @current_tab
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
    
    # Get the filtered count BEFORE pagination
    @filtered_reviews_count = @reviews.count
    
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
    
    respond_to do |format|
      format.html { redirect_to admin_reviews_path, notice: 'Review was successfully deleted.' }
      format.json { render json: { success: true, message: 'Review was successfully deleted.' } }
    end
  end

  def approve
    @review.approve!(current_user)
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: admin_reviews_path, notice: 'Review was approved.') }
      format.json { 
        render json: { 
          success: true, 
          message: 'Review was approved.',
          review: {
            id: @review.id,
            approved: @review.approved?,
            featured: @review.featured?,
            can_be_featured: @review.can_be_featured?,
            status_badge: render_to_string(partial: 'status_badge', locals: { review: @review }, formats: [:html])
          }
        }
      }
    end
  end

  def unapprove
    @review.unapprove!
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: admin_reviews_path, notice: 'Review was unapproved.') }
      format.json { 
        render json: { 
          success: true, 
          message: 'Review was unapproved.',
          review: {
            id: @review.id,
            approved: @review.approved?,
            featured: @review.featured?,
            can_be_featured: @review.can_be_featured?,
            status_badge: render_to_string(partial: 'status_badge', locals: { review: @review }, formats: [:html])
          }
        }
      }
    end
  end

  def toggle_featured
    if @review.can_be_featured?
      @review.toggle_featured!
      status = @review.featured? ? 'featured' : 'unfeatured'
      
      respond_to do |format|
        format.html { redirect_back(fallback_location: admin_reviews_path, notice: "Review was #{status}.") }
        format.json { 
          render json: { 
            success: true, 
            message: "Review was #{status}.",
            review: {
              id: @review.id,
              approved: @review.approved?,
              featured: @review.featured?,
              can_be_featured: @review.can_be_featured?,
              status_badge: render_to_string(partial: 'status_badge', locals: { review: @review }, formats: [:html])
            }
          }
        }
      end
    else
      respond_to do |format|
        format.html { redirect_back(fallback_location: admin_reviews_path, alert: 'Only approved reviews can be featured.') }
        format.json { render json: { success: false, message: 'Only approved reviews can be featured.' }, status: :unprocessable_entity }
      end
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