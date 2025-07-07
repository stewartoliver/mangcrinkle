class PasswordsController < Devise::PasswordsController
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    
    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      
      # Mark admin as activated when they set their password
      if resource.admin? && resource.pending_activation?
        resource.activate!
      end
      
      if resource_class.sign_in_after_reset_password
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message!(:notice, flash_message)
        resource.after_database_authentication
        sign_in(resource_name, resource)
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
end 