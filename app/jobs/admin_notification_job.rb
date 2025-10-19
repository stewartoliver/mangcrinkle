class AdminNotificationJob < ApplicationJob
  queue_as :default
  
  # Prevent duplicate job processing
  def self.perform_later(order_id, admin_id)
    # Check if job is already enqueued for this order and admin
    existing_job = GoodJob::Job.where(
      job_class: 'AdminNotificationJob',
      arguments: [order_id, admin_id],
      finished_at: nil
    ).first
    
    if existing_job
      Rails.logger.info "AdminNotificationJob already enqueued for order #{order_id} and admin #{admin_id}, skipping duplicate"
      return existing_job
    end
    
    super(order_id, admin_id)
  end

  def perform(order_id, admin_id)
    order = Order.find(order_id)
    admin = User.find(admin_id)
    
    # Additional safety check - only send if order is in a valid state
    unless order.status.in?(['pending', 'processing', 'completed'])
      Rails.logger.warn "AdminNotificationJob skipped: Order #{order_id} has invalid status '#{order.status}'"
      return
    end
    
    # Check if admin still wants notifications
    prefs = admin.notification_preferences
    if prefs.new_order_notifications?
      AdminMailer.new_order_notification(order, admin).deliver_now
      Rails.logger.info "Admin notification email sent for order #{order_id} to admin #{admin_id}"
    else
      Rails.logger.info "Admin #{admin_id} has notifications disabled, skipping order #{order_id}"
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "AdminNotificationJob failed: Order #{order_id} or Admin #{admin_id} not found - #{e.message}"
  rescue => e
    Rails.logger.error "AdminNotificationJob failed: #{e.message}"
    raise e
  end
end
