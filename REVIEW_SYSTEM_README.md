# Mang Crinkle Review System

A comprehensive review system for the Mang Crinkle cookies website with token-based invitations, spam protection, and admin management.

## Features

### 🌟 Core Features
- **Token-based Review System**: Secure one-time-use links for review submissions
- **Automatic Review Invitations**: Sent automatically when orders are marked as completed
- **Manual Review Invitations**: Admins can manually invite customers or testers
- **Spam Protection**: IP and email rate limiting, honeypot fields
- **Admin Moderation**: Approve, reject, feature, and manage reviews
- **Verified Purchase Badges**: Reviews linked to orders show verification
- **Public Reviews Display**: Beautiful public-facing reviews page

### 🛡️ Security Features
- Secure token generation using `SecureRandom.urlsafe_base64(32)`
- 30-day token expiration
- One-time use tokens
- Rate limiting: 3 attempts per IP/hour, 2 per email/hour
- Honeypot field detection
- Admin notifications for new reviews

## System Components

### Models
- **Review**: Main review model with rating, title, content, and approval status
- **ReviewInvite**: Token-based invitation system
- **ReviewSpamTracker**: Rate limiting and spam protection
- **Order**: Enhanced with automatic review invite creation

### Controllers
- **ReviewsController**: Public review submission and display
- **Admin::ReviewsController**: Admin review management with bulk actions
- **Admin::ReviewInvitesController**: Admin invitation management

### Background Jobs
- **CleanupSpamTrackersJob**: Automatically cleans up old spam tracking records
- **ReviewMailer**: Handles invitation and notification emails

## Usage

### For Customers

#### Automatic Invitations
1. Customer places an order
2. Admin marks order as "completed"
3. System automatically creates and sends review invitation after 5 minutes
4. Customer receives email with secure review link
5. Customer clicks link to submit review

#### Manual Reviews
1. Customer can visit `/reviews/new` to submit a review
2. Must pass spam protection checks
3. Review goes to admin for approval

### For Admins

#### Review Management
1. Visit `/admin/reviews` to manage all reviews
2. **Approve/Unapprove**: Control which reviews are public
3. **Feature/Unfeature**: Highlight best reviews
4. **Bulk Actions**: Select multiple reviews for batch operations
5. **Search & Filter**: Find reviews by status, rating, or content

#### Review Invitations
1. Visit `/admin/review_invites` to manage invitations
2. **Send Manual Invitations**: Create invitations for specific customers
3. **Link to Orders**: Associate invitations with orders for verified purchase badges
4. **Resend Invitations**: Resend active invitations
5. **Bulk Cleanup**: Remove expired invitations

#### Dashboard Statistics
- Total reviews and average rating
- Pending reviews requiring approval
- Featured reviews count
- Recent review activity

## Configuration

### Environment Variables
- `ADMIN_EMAIL`: Admin email for notifications
- `RAILS_ENV`: Environment (development/production)

### Email Configuration
Review invitations and admin notifications are sent via ActionMailer. Configure your email settings in:
- `config/environments/production.rb`
- `config/environments/development.rb`

### Scheduled Jobs
The `CleanupSpamTrackersJob` should run daily to clean up old spam tracking records:

```bash
# Add to crontab for production
0 2 * * * cd /path/to/app && bundle exec rails runner "CleanupSpamTrackersJob.perform_later"
```

## API Endpoints

### Public Routes
- `GET /reviews` - Public reviews listing
- `GET /reviews/new` - Review submission form
- `POST /reviews` - Submit review
- `GET /reviews/new?token=TOKEN` - Token-based review form

### Admin Routes
- `GET /admin/reviews` - Admin review management
- `PATCH /admin/reviews/:id/approve` - Approve review
- `PATCH /admin/reviews/:id/unapprove` - Unapprove review
- `PATCH /admin/reviews/:id/toggle_featured` - Toggle featured status
- `PATCH /admin/reviews/bulk_approve` - Bulk approve reviews
- `DELETE /admin/reviews/bulk_destroy` - Bulk delete reviews

- `GET /admin/review_invites` - Admin invitation management
- `POST /admin/review_invites` - Create new invitation
- `PATCH /admin/review_invites/:id/resend` - Resend invitation
- `DELETE /admin/review_invites/bulk_cleanup` - Cleanup expired invitations

## Database Schema

### Reviews Table
```sql
- id: Primary key
- user_id: Associated user (optional)
- order_id: Associated order (optional)
- customer_name: Customer name
- email: Customer email
- rating: 1-5 star rating
- title: Review title (optional, max 100 chars)
- content: Review content (required, max 500 chars)
- approved: Admin approval status
- featured: Featured status
- admin_notes: Admin notes
- approved_at: Approval timestamp
- approved_by_id: Admin who approved
```

### Review Invites Table
```sql
- id: Primary key
- order_id: Associated order (optional)
- email: Customer email
- name: Customer name
- token: Secure token (unique)
- expires_at: Expiration timestamp
- used_at: Usage timestamp
- sent_at: Send timestamp
- admin_notes: Admin notes
- invite_type: 'order' or 'manual'
```

### Review Spam Trackers Table
```sql
- id: Primary key
- ip_address: IP address
- email: Email address
- user_agent: Browser user agent
- attempt_count: Number of attempts
- created_at: Timestamp
```

## Customization

### Email Templates
Customize email templates in:
- `app/views/review_mailer/review_invite.html.erb`
- `app/views/review_mailer/review_invite.text.erb`
- `app/views/review_mailer/new_review_notification.html.erb`
- `app/views/review_mailer/new_review_notification.text.erb`

### Spam Protection Settings
Adjust rate limits in `app/models/review_spam_tracker.rb`:
```ruby
# Current limits
ip_attempts >= 3    # 3 attempts per IP per hour
email_attempts >= 2 # 2 attempts per email per hour
```

### Review Display
Customize the public reviews page in `app/views/reviews/index.html.erb`

## Troubleshooting

### Common Issues

1. **Reviews not appearing**: Check if they're approved in admin panel
2. **Invitations not sending**: Check email configuration and background job processing
3. **Spam protection blocking legitimate users**: Adjust rate limits or check IP/email filters
4. **Tokens not working**: Verify token hasn't expired or been used

### Logs
Check Rails logs for:
- Review invite creation: `"Review invite created and sent for Order ##{id}"`
- Spam protection: `"Honeypot field filled - potential spam"`
- Cleanup job: `"Cleaned up #{count} old spam tracker records"`

### Manual Commands
```bash
# Run cleanup job manually
rails runner "CleanupSpamTrackersJob.perform_now"

# Check review statistics
rails console
> Review.approved.count
> ReviewInvite.active.count
> ReviewSpamTracker.recent.count
```

## Development

### Running Tests
```bash
# Run all tests
rails test

# Run specific test files
rails test test/models/review_test.rb
rails test test/controllers/reviews_controller_test.rb
```

### Seeding Data
```bash
# Create sample reviews and invitations
rails db:seed
```

### Database Migrations
```bash
# Run pending migrations
rails db:migrate

# Rollback if needed
rails db:rollback
```

## Production Deployment

1. **Environment Setup**: Configure production email settings
2. **Database Migration**: Run `rails db:migrate`
3. **Scheduled Jobs**: Set up cron job for cleanup
4. **Admin User**: Create admin user with `rails admin:create_user`
5. **Email Testing**: Test review invitations and notifications

## Support

For issues or questions about the review system:
1. Check the Rails logs for error messages
2. Verify email configuration for invitation sending
3. Ensure background job processing is working
4. Check admin panel for pending reviews and invitations

---

**Version**: 1.0  
**Last Updated**: January 2025  
**Author**: Mang Crinkle Development Team 