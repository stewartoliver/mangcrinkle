class PasswordsController < Devise::PasswordsController
  # Skip Devise's authenticate_user! filter that causes "already signed in" error
  skip_before_action :require_no_authentication, only: [:edit, :update]
  
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    
    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      
      # Mark admin as activated when they set their password
      if resource.admin? && resource.pending_activation?
        resource.activate!
      end
      
      # Clear any existing custom session first
      custom_sign_out(current_user) if respond_to?(:custom_sign_out) && current_user
      
      if resource_class.sign_in_after_reset_password
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message!(:notice, flash_message)
        resource.after_database_authentication
        
        # Sign in using Devise
        sign_in(resource_name, resource)
        
        # Also set up custom session for admin users
        if resource.admin? && respond_to?(:custom_sign_in)
          custom_sign_in(resource)
        end
      else
        set_flash_message!(:notice, :updated_not_active)
      end
      
      # Redirect based on user type
      redirect_to after_resetting_password_path_for(resource)
    else
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  # Override the default redirect path to avoid new_user_session_path error
  def after_resetting_password_path_for(resource)
    if resource.admin?
      admin_dashboard_path
    else
      # For customers, redirect to home page since we don't have sessions
      root_path
    end
  end

  private

  # Define resource_params to permit the password reset parameters
  def resource_params
    params.require(resource_name).permit(:reset_password_token, :password, :password_confirmation)
  end
end 