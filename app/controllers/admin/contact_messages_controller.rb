class Admin::ContactMessagesController < Admin::BaseController
  before_action :set_contact_message, only: [:show, :edit, :update, :destroy, :respond]

  def index
    @contact_messages = ContactMessage.includes(:user, :contact_responses)
                                     .recent
                                     .page(params[:page])
                                     .per(20)
    
    # Filter by user if provided
    if params[:user_id].present?
      @contact_messages = @contact_messages.where(user_id: params[:user_id])
      @filtered_user = User.find_by(id: params[:user_id])
    end
    
    # Filter by status if provided
    if params[:status].present?
      @contact_messages = @contact_messages.where(status: params[:status])
    end
    
    # Filter by priority if provided
    if params[:priority].present?
      @contact_messages = @contact_messages.where(priority: params[:priority])
    end
    
    @stats = {
      total: ContactMessage.count,
      new: ContactMessage.where(status: 'new').count,
      in_progress: ContactMessage.where(status: 'in_progress').count,
      resolved: ContactMessage.where(status: 'resolved').count,
      urgent: ContactMessage.where(priority: 'urgent').count
    }
  end

  def show
    @contact_responses = @contact_message.contact_responses.recent
    @new_response = ContactResponse.new
  end

  def edit
    # For updating status, priority, etc.
  end

  def update
    if @contact_message.update(contact_message_params)
      redirect_to admin_contact_message_path(@contact_message), notice: 'Contact message updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def respond
    @contact_response = @contact_message.contact_responses.build(contact_response_params)
    @contact_response.admin_user = current_admin_user.email
    @contact_response.sent_at = Time.current
    
    if @contact_response.save
      # Update the contact message status
      @contact_message.update(status: 'responded', responded_at: Time.current, admin_user: current_admin_user.email)
      
      # Send the response email
      ContactMailer.response_email(@contact_response).deliver_later
      
      redirect_to admin_contact_message_path(@contact_message), notice: 'Response sent successfully.'
    else
      @contact_responses = @contact_message.contact_responses.recent
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @contact_message.destroy
    redirect_to admin_contact_messages_path, notice: 'Contact message deleted successfully.'
  end

  def bulk_update
    contact_message_ids = params[:contact_message_ids] || []
    action = params[:bulk_action]
    
    case action
    when 'mark_resolved'
      ContactMessage.where(id: contact_message_ids).update_all(status: 'resolved')
      redirect_to admin_contact_messages_path, notice: 'Messages marked as resolved.'
    when 'mark_in_progress'
      ContactMessage.where(id: contact_message_ids).update_all(status: 'in_progress')
      redirect_to admin_contact_messages_path, notice: 'Messages marked as in progress.'
    when 'delete'
      ContactMessage.where(id: contact_message_ids).destroy_all
      redirect_to admin_contact_messages_path, notice: 'Messages deleted.'
    else
      redirect_to admin_contact_messages_path, alert: 'Invalid action.'
    end
  end

  private

  def set_contact_message
    @contact_message = ContactMessage.find(params[:id])
  end

  def contact_message_params
    params.require(:contact_message).permit(:status, :priority, :admin_user)
  end

  def contact_response_params
    params.require(:contact_response).permit(:response)
  end

  def current_admin_user
    # Assuming you have a current_user method that returns the logged-in admin
    current_user
  end
end 