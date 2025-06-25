class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  layout 'admin'

  private

  def authenticate_user!
    unless user_signed_in? && current_user.admin?
      redirect_to admin_login_path, alert: 'Please sign in to access the admin area.'
    end
  end
end 