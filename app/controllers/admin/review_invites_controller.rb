class Admin::ReviewInvitesController < Admin::BaseController
  before_action :set_review_invite, only: [:show, :destroy, :resend]

  def index
    @review_invites = ReviewInvite.includes(:order)
    
    case params[:status]
    when 'active'
      @review_invites = @review_invites.active
    when 'used'
      @review_invites = @review_invites.used
    when 'expired'
      @review_invites = @review_invites.expired
    end
    
    @review_invites = @review_invites.where(invite_type: params[:type]) if params[:type].present?
    @review_invites = @review_invites.where('email ILIKE ?', "%#{params[:search]}%") if params[:search].present?
    
    @review_invites = @review_invites.order(created_at: :desc).page(params[:page]).per(20)
    
    # Calculate stats
    @stats = {
      total: ReviewInvite.count,
      active: ReviewInvite.active.count,
      used: ReviewInvite.used.count,
      expired: ReviewInvite.expired.count
    }
  end

  def show
  end

  def new
    @review_invite = ReviewInvite.new
    @orders = Order.recent.limit(100) # For order selection dropdown
  end

  def create
    @review_invite = ReviewInvite.new(review_invite_params)
    @review_invite.invite_type = 'manual'
    @review_invite.admin_notes = "Created by #{current_user.email}"
    
    if @review_invite.save
      # Send the invitation email
      ReviewMailer.review_invite(@review_invite).deliver_later
      @review_invite.update!(sent_at: Time.current)
      
      redirect_to admin_review_invites_path, notice: 'Review invitation created and sent successfully!'
    else
      @orders = Order.recent.limit(100)
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @review_invite.destroy
    redirect_to admin_review_invites_path, notice: 'Review invitation was deleted.'
  end

  def resend
    if @review_invite.active?
      ReviewMailer.review_invite(@review_invite).deliver_later
      @review_invite.update!(sent_at: Time.current)
      redirect_back(fallback_location: admin_review_invites_path, notice: 'Review invitation resent successfully!')
    else
      redirect_back(fallback_location: admin_review_invites_path, alert: 'Cannot resend inactive invitations.')
    end
  end

  def bulk_cleanup
    expired_count = ReviewInvite.expired.count
    ReviewInvite.expired.destroy_all
    
    redirect_to admin_review_invites_path, notice: "#{expired_count} expired invitations were cleaned up."
  end

  def quick_link
    # Show the quick link generation form
  end

  def create_quick_link
    # Create a quick review link without requiring an order or customer details
    @review_invite = ReviewInvite.new
    @review_invite.name = "Quick Link Customer" # Placeholder name
    @review_invite.email = "quicklink@placeholder.com" # Placeholder email
    @review_invite.invite_type = 'quick_link' # Special type for quick links
    @review_invite.admin_notes = "Quick link created by #{current_user.email}"
    
    if @review_invite.save
      redirect_to quick_link_created_admin_review_invites_path(token: @review_invite.token)
    else
      render :quick_link
    end
  rescue => e
    Rails.logger.error "Failed to create quick link: #{e.message}"
    redirect_to admin_review_invites_path, alert: 'Failed to generate quick link.'
  end

  def quick_link_created
    @review_invite = ReviewInvite.find_by_token(params[:token])
    unless @review_invite
      redirect_to admin_review_invites_path, alert: 'Invalid or expired link.'
      return
    end
    @review_link = new_review_url(token: @review_invite.token, host: request.host_with_port)
  end

  private

  def set_review_invite
    @review_invite = ReviewInvite.find(params[:id])
  end

  def review_invite_params
    params.require(:review_invite).permit(:name, :email, :order_id, :admin_notes)
  end
end 