# Order Toggle Configuration
# This allows you to easily disable customer orders during development
# Set to false to disable all customer order functionality

Rails.application.configure do
  # Set this to false to disable customer orders
  config.orders_enabled = false
  
  # Optional: Add a reason for why orders are disabled
  config.orders_disabled_reason = "We're currently in development mode. Orders will be available soon!"
end
