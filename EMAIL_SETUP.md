# Email Configuration for mangcrinkle@gmail.com

## Step-by-Step Setup

### 1. Set up Gmail App Password

1. **Go to your Google Account**: https://myaccount.google.com/
2. **Click "Security"** in the left sidebar
3. **Enable 2-Step Verification** if not already enabled
4. **Go to "App passwords"** (under 2-Step Verification)
5. **Generate a new app password**:
   - Select app: "Mail"
   - Select device: "Other" and type "Mang Crinkle Website"
   - Click "Generate"
   - **Copy the 16-character password** (it looks like: `abcd efgh ijkl mnop`)

### 2. Set Environment Variables on Your Server

You need to set these **exact** environment variables on your production server:

```bash
APP_HOST=your-actual-domain.com
SMTP_USERNAME=mangcrinkle@gmail.com
SMTP_PASSWORD=your-16-character-app-password
```

### 3. How to Set Environment Variables

**If you're using Fly.io:**
```bash
fly secrets set APP_HOST=your-domain.com
fly secrets set SMTP_USERNAME=mangcrinkle@gmail.com
fly secrets set SMTP_PASSWORD=abcdefghijklmnop
```

**If you're using Heroku:**
```bash
heroku config:set APP_HOST=your-domain.com
heroku config:set SMTP_USERNAME=mangcrinkle@gmail.com
heroku config:set SMTP_PASSWORD=abcdefghijklmnop
```

**If you're using another platform:**
Add these to your environment variables or server configuration.

### 4. Deploy Your Changes

After setting the environment variables, restart your application:

**Fly.io:**
```bash
fly deploy
```

**Heroku:**
```bash
git push heroku main
```

### 5. Test It

1. Go to your admin panel
2. Create a new customer
3. Edit the customer and change type to "admin"
4. Click "Send Activation Email"
5. Check `mangcrinkle@gmail.com` inbox (and spam folder)

## What Each Variable Does

- `APP_HOST`: Your website domain (so email links work correctly)
- `SMTP_USERNAME`: Your Gmail address (`mangcrinkle@gmail.com`)
- `SMTP_PASSWORD`: The 16-character app password from Google (NOT your regular Gmail password)

## Common Issues

1. **Using regular Gmail password instead of app password** - This won't work
2. **Forgetting to enable 2-Step Verification** - Required for app passwords
3. **Wrong domain in APP_HOST** - Links in emails will be broken
4. **Not restarting the app** - Environment variables need app restart to take effect

## If It Still Doesn't Work

Check your server logs for errors:
```bash
# Look for lines containing "AdminMailer" or "SMTP"
fly logs  # or heroku logs --tail
```

The most common error is using the wrong password - make sure you're using the 16-character app password, not your regular Gmail password. 