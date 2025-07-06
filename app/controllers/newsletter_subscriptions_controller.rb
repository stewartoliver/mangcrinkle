class NewsletterSubscriptionsController < ApplicationController
  def create
    email = params[:email]&.downcase&.strip
    
    if email.blank?
      redirect_to root_path, alert: 'Please enter a valid email address.'
      return
    end

    @user = User.find_by(email: email)
    
    if @user
      # Update existing user
      if @user.newsletter_subscribed?
        redirect_to root_path, notice: 'You\'re already subscribed to our newsletter!'
      else
        @user.update!(newsletter_subscribed: true)
        send_welcome_email(@user)
        redirect_to root_path, notice: 'Thank you for subscribing to our newsletter!'
      end
    else
      # Create new customer user
      @user = User.create!(
        email: email,
        user_type: 'customer',
        newsletter_subscribed: true
      )
      send_welcome_email(@user)
      redirect_to root_path, notice: 'Thank you for subscribing to our newsletter!'
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to root_path, alert: 'There was an error with your subscription. Please try again.'
  end

  def unsubscribe
    token = params[:token]
    email = params[:email]
    
    # Simple token validation (you might want to implement a more secure token system)
    if token == generate_unsubscribe_token(email)
      user = User.find_by(email: email)
      if user
        user.update!(newsletter_subscribed: false)
        render :unsubscribed
      else
        redirect_to root_path, alert: 'Invalid unsubscribe link.'
      end
    else
      redirect_to root_path, alert: 'Invalid unsubscribe link.'
    end
  end

  private

  def send_welcome_email(user)
    CustomerMailer.welcome_email(user).deliver_later
  end

  def generate_unsubscribe_token(email)
    # Simple token generation - in production, use a more secure method
    Digest::SHA256.hexdigest("#{email}#{Rails.application.secret_key_base}")[0..15]
  end
end 