class Admin::SessionsController < ApplicationController
  layout 'devise'

  def new
    redirect_to admin_dashboard_path if user_signed_in?
  end

  def create
    user = User.find_by(email: params[:email])
    
    if user&.valid_password?(params[:password]) && user.admin?
      sign_in(user)
      redirect_to admin_dashboard_path, notice: 'Signed in successfully.'
    else
      flash.now[:alert] = 'Invalid email or password.'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out(current_user)
    redirect_to admin_login_path, notice: 'Signed out successfully.'
  end
end 