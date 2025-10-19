# Order Toggle Configuration

This configuration allows you to easily disable customer orders during development or maintenance periods.

## How to Use

### To Disable Orders:
1. Open `config/initializers/order_toggle.rb`
2. Change `config.orders_enabled = true` to `config.orders_enabled = false`
3. Optionally update the `orders_disabled_reason` message
4. Restart your Rails server

### To Re-enable Orders:
1. Open `config/initializers/order_toggle.rb`
2. Change `config.orders_enabled = false` to `config.orders_enabled = true`
3. Restart your Rails server

## What Happens When Orders Are Disabled:

1. **Cart Page**: The "Proceed to Checkout" button is replaced with a disabled "Orders Temporarily Disabled" button
2. **Maintenance Message**: A helpful message appears explaining why orders are unavailable
3. **Controller Protection**: Direct access to `/orders/new` and order creation is blocked
4. **User Experience**: Customers can still browse products and add items to cart, but cannot complete purchases

## Example Configuration:

```ruby
# Disable orders with custom message
config.orders_enabled = false
config.orders_disabled_reason = "We're currently updating our system. Orders will be available again on Monday!"

# Enable orders (normal operation)
config.orders_enabled = true
config.orders_disabled_reason = "We're currently in development mode. Orders will be available soon!"
```

## Notes:

- This is a simple hardcoded toggle perfect for early development stages
- The configuration is loaded at application startup, so you need to restart the server after changes
- Customers can still browse and add items to cart - only the checkout process is disabled
- Admin functionality remains unaffected
