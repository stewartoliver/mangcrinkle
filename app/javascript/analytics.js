// Google Analytics initialization
document.addEventListener('DOMContentLoaded', function () {
    if (window.GOOGLE_ANALYTICS_ID && window.gtag) {
        window.dataLayer = window.dataLayer || [];
        function gtag() { dataLayer.push(arguments); }
        gtag('js', new Date());
        gtag('config', window.GOOGLE_ANALYTICS_ID);

        // Track form submissions
        // Track contact form submissions
        const contactForm = document.querySelector('form[action*="contact"]');
        if (contactForm) {
            contactForm.addEventListener('submit', function () {
                gtag('event', 'form_submit', {
                    'form_name': 'contact_form'
                });
            });
        }

        // Track order form submissions (customer-facing only)
        const orderForm = document.querySelector('form[action*="orders"]:not([action*="admin"])');
        if (orderForm) {
            orderForm.addEventListener('submit', function () {
                gtag('event', 'form_submit', {
                    'form_name': 'order_form'
                });
            });
        }

        // Track review form submissions
        const reviewForm = document.querySelector('form[action*="reviews"]');
        if (reviewForm) {
            reviewForm.addEventListener('submit', function () {
                gtag('event', 'form_submit', {
                    'form_name': 'review_form'
                });
            });
        }

        // Track newsletter subscriptions
        const newsletterForm = document.querySelector('form[action*="newsletter"]');
        if (newsletterForm) {
            newsletterForm.addEventListener('submit', function () {
                gtag('event', 'form_submit', {
                    'form_name': 'newsletter_subscription'
                });
            });
        }

        // Google Analytics initialized
    } else {
        console.log('Google Analytics not available');
    }
});
