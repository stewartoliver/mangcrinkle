# Be sure to restart your server when you modify this file.

# Configure Rack::Attack for rate limiting
Rails.application.configure do
  config.middleware.use Rack::Attack
end

# Configure rate limiting rules
Rack::Attack.throttled_responder = lambda do |env|
  match_data = env['rack.attack.match_data']
  now = match_data[:epoch_time]

  headers = {
    'Content-Type' => 'text/html',
    'X-RateLimit-Limit' => match_data[:limit].to_s,
    'X-RateLimit-Remaining' => '0',
    'X-RateLimit-Reset' => (now + (match_data[:period] - now % match_data[:period])).to_s
  }

  [429, headers, ['<h1>Rate limit exceeded. Please try again later.</h1>']]
end

Rack::Attack.throttle('order_submissions', limit: 5, period: 1.hour) do |req|
  if req.path == '/orders' && req.post?
    req.ip
  end
end

Rack::Attack.throttle('contact_submissions', limit: 3, period: 1.hour) do |req|
  if req.path == '/contact_messages' && req.post?
    req.ip
  end
end

Rack::Attack.throttle('review_submissions', limit: 2, period: 1.hour) do |req|
  if req.path == '/reviews' && req.post?
    req.ip
  end
end

Rack::Attack.throttle('newsletter_subscriptions', limit: 3, period: 1.hour) do |req|
  if req.path == '/newsletter_subscriptions' && req.post?
    req.ip
  end
end

Rack::Attack.throttle('req/ip', limit: 300, period: 5.minutes) do |req|
  req.ip
end

Rack::Attack.throttle('admin_login_attempts', limit: 5, period: 20.minutes) do |req|
  if req.path == '/admin' && req.post?
    req.ip
  end
end

Rack::Attack.safelist('allow-localhost') do |req|
  '127.0.0.1' == req.ip || '::1' == req.ip
end
