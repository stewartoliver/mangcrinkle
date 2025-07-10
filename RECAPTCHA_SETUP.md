# reCAPTCHA Setup Guide for MangCrinkle

This guide explains how to set up Google reCAPTCHA to protect your customer-facing forms from spam and bot submissions.

## Overview

reCAPTCHA has been added to protect these forms:
- ✅ **Contact Form** (`/contact`) - Prevents spam messages
- ✅ **Order Form** (`/orders/new`) - Protects order submissions  
- ✅ **Review Form** (`/reviews/new`) - Prevents fake reviews
- ✅ **Newsletter Subscription** (homepage) - Blocks bot subscriptions

## Automatic Localhost Deactivation

reCAPTCHA is **automatically disabled** when:
- Running in `development` or `test` environments
- Accessing via `localhost` or `127.0.0.1`
- Environment variables are missing

This means you can develop and test locally without any reCAPTCHA interference!

## Setup Instructions

### Step 1: Get reCAPTCHA Keys

1. **Visit Google reCAPTCHA Admin**: https://www.google.com/recaptcha/admin
2. **Create a new site** with these settings:
   - **Label**: MangCrinkle Website
   - **reCAPTCHA type**: reCAPTCHA v2 → "I'm not a robot" Checkbox
   - **Domains**: Add your production domain (e.g., `yourdomain.com`)
   - **Accept Terms** and click Submit

3. **Copy your keys**:
   - **Site Key** (public) - goes in frontend forms
   - **Secret Key** (private) - for server verification

### Step 2: Set Environment Variables

**For Fly.io deployment:**
```bash
fly secrets set RECAPTCHA_SITE_KEY=
fly secrets set RECAPTCHA_SECRET_KEY=
fly deploy
```

**For Heroku deployment:**
```bash
heroku config:set RECAPTCHA_SITE_KEY=your-public-site-key-here
heroku config:set RECAPTCHA_SECRET_KEY=your-private-secret-key-here
git push heroku main
```

**For other hosting:**
Set these environment variables in your hosting platform:
- `RECAPTCHA_SITE_KEY=your-public-site-key-here`
- `RECAPTCHA_SECRET_KEY=your-private-secret-key-here`

### Step 3: Test the Implementation

1. **Deploy your changes** to production
2. **Visit your live website** (not localhost)
3. **Try submitting each protected form**:
   - Contact form at `/contact`
   - Order form at `/orders/new` (add items to cart first)
   - Review form at `/reviews/new`
   - Newsletter subscription on homepage

4. **Verify reCAPTCHA appears** and form submission works

## Development Workflow

### Local Development
- reCAPTCHA widgets **won't appear** on localhost
- Forms **work normally** without verification
- **No setup needed** for local development

### Testing on Staging
- Set the environment variables on your staging server
- Add your staging domain to reCAPTCHA admin console
- Test all forms to ensure reCAPTCHA works properly

### Production Deployment
- Ensure environment variables are set
- Add your production domain to reCAPTCHA admin console
- Monitor for any form submission issues

## Troubleshooting

### reCAPTCHA Not Showing
- ✅ Check environment variables are set correctly
- ✅ Ensure you're not on localhost/development
- ✅ Verify domain is added in reCAPTCHA admin console

### Form Submission Failing
- ✅ Check server logs for reCAPTCHA verification errors
- ✅ Ensure secret key is correct
- ✅ Verify network isn't blocking Google reCAPTCHA

### Testing Issues
- ✅ Use production or staging environment for testing
- ✅ Clear browser cache and cookies
- ✅ Try different browsers/devices

## Security Benefits

✅ **Spam Prevention**: Blocks automated form submissions  
✅ **Bot Protection**: Identifies and stops malicious bots  
✅ **User Experience**: Minimal friction for real users  
✅ **Development Friendly**: No interference during development  
✅ **Smart Detection**: Often works invisibly for legitimate users

## Configuration Details

The reCAPTCHA implementation includes:

- **Smart Environment Detection**: Automatically disabled on localhost
- **Fallback Handling**: Forms work if reCAPTCHA fails to load
- **Error Messages**: Clear feedback when verification fails
- **Minimal UI Impact**: Uses Google's standard styling

## Monitoring

After deployment, monitor:
- **Form submission rates** (should stay normal for legitimate users)
- **Contact message quality** (should reduce spam)
- **User complaints** about form difficulty
- **Server logs** for reCAPTCHA errors

---

**Need Help?** 
- Check the [Google reCAPTCHA documentation](https://developers.google.com/recaptcha)
- Review your admin console for verification statistics
- Test forms thoroughly on staging before production deployment 