// reCAPTCHA configuration
document.addEventListener('DOMContentLoaded', function () {
    // Set reCAPTCHA site key from Rails
    if (typeof window !== 'undefined' && window.RECAPTCHA_SITE_KEY) {
        // reCAPTCHA site key loaded
    } else {
        console.log('reCAPTCHA site key not available, skipping initialization');
    }
});
