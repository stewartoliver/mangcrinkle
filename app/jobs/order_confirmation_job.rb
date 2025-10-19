class OrderConfirmationJob < ApplicationJob
  queue_as :default
  
  # Prevent duplicate job processing
  def self.perform_later(order_id)
    # Check if job is already enqueued for this order
    existing_job = GoodJob::Job.where(
      job_class: 'OrderConfirmationJob',
      arguments: [order_id],
      finished_at: nil
    ).first
    
    if existing_job
      Rails.logger.info "OrderConfirmationJob already enqueued for order #{order_id}, skipping duplicate"
      return existing_job
    end
    
    super(order_id)
  end

  def perform(order_id)
    order = Order.find(order_id)
    
    # Additional safety check - only send if order is in a valid state
    unless order.status.in?(['pending', 'processing', 'completed'])
      Rails.logger.warn "OrderConfirmationJob skipped: Order #{order_id} has invalid status '#{order.status}'"
      return
    end
    
    CustomerMailer.order_confirmation(order).deliver_now
    Rails.logger.info "Order confirmation email sent for order #{order_id}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "OrderConfirmationJob failed: Order #{order_id} not found - #{e.message}"
  rescue => e
    Rails.logger.error "OrderConfirmationJob failed: #{e.message}"
    raise e
  end
end
