class ContactMessagesController < ApplicationController
  before_action :find_or_create_user, only: [:create]

  def create
    @contact_message = @user.contact_messages.build(contact_message_params)
    
    if @contact_message.save
      # Send notifications to admins who want contact form notifications
      notify_admins_of_new_contact
      
      redirect_to contact_success_path
    else
      redirect_to contact_path, alert: 'There was an error sending your message. Please try again.'
    end
  end

  private

  def contact_message_params
    params.require(:contact_message).permit(:subject, :message, :priority)
  end

  def user_params
    params.require(:contact_message).permit(:name, :email)
  end

  def find_or_create_user
    email = user_params[:email]&.downcase&.strip
    name_parts = user_params[:name]&.split(' ', 2) || []
    first_name = name_parts[0]
    last_name = name_parts[1]

    @user = User.find_by(email: email)
    
    unless @user
      @user = User.create!(
        email: email,
        user_type: 'customer',
        first_name: first_name,
        last_name: last_name
      )
    end
  end

  def notify_admins_of_new_contact
    User.admins.includes(:admin_notification_preference).each do |admin|
      preferences = admin.notification_preferences
      if preferences.contact_form_notifications?
        AdminMailer.new_contact_message(@contact_message, admin).deliver_later
      end
    end
  end
end 