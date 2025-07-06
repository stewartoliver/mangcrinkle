class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contact_message_count
  layout 'admin'

  private

  def authenticate_user!
    unless user_signed_in? && current_user.admin?
      redirect_to admin_login_path, alert: 'Please sign in to access the admin area.'
    end
  end

  def set_contact_message_count
    @new_contact_messages_count = ContactMessage.where(status: 'new').count
  end
end 