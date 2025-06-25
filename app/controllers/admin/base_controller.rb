class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  layout 'admin'

  private

  def authenticate_user!
    unless current_user
      redirect_to admin_login_path, alert: 'Please sign in to access the admin area.'
    end
  end
end 