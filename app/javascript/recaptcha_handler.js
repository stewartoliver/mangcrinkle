// reCAPTCHA v3 Handler for better user experience and reliability
class RecaptchaHandler {
    constructor() {
        this.siteKey = window.RECAPTCHA_SITE_KEY;
        this.isLoaded = false;
        this.retryCount = 0;
        this.maxRetries = 3;
        this.init();
    }

    init() {
        if (!this.siteKey) {
            return;
        }

        // Load reCAPTCHA script if not already loaded
        if (!window.grecaptcha) {
            this.loadRecaptchaScript();
        } else {
            this.isLoaded = true;
            this.initializeRecaptcha();
        }
    }

    loadRecaptchaScript() {
        const script = document.createElement('script');
        script.src = `https://www.google.com/recaptcha/api.js?render=${this.siteKey}`;
        script.async = true;
        script.defer = true;

        script.onload = () => {
            this.isLoaded = true;
            this.initializeRecaptcha();
        };

        script.onerror = () => {
            this.handleRecaptchaError();
        };

        document.head.appendChild(script);
    }

    initializeRecaptcha() {
        if (window.grecaptcha && window.grecaptcha.ready) {
            window.grecaptcha.ready(() => {
                this.setupFormHandlers();
            });
        } else {
            // Fallback for older browsers or slow loading
            setTimeout(() => {
                if (window.grecaptcha) {
                    this.setupFormHandlers();
                } else {
                    this.handleRecaptchaError();
                }
            }, 2000);
        }
    }

    setupFormHandlers() {
        // Handle order form
        const orderForm = document.querySelector('form[action*="orders"]');
        if (orderForm) {
            this.setupForm(orderForm, 'order_form');
        }

        // Handle contact form
        const contactForm = document.querySelector('form[action*="contact"]');
        if (contactForm) {
            this.setupForm(contactForm, 'contact_form');
        }

        // Handle review form
        const reviewForm = document.querySelector('form[action*="reviews"]');
        if (reviewForm) {
            this.setupForm(reviewForm, 'review_form');
        }

        // Handle newsletter form
        const newsletterForm = document.querySelector('form[action*="newsletter"]');
        if (newsletterForm) {
            this.setupForm(newsletterForm, 'newsletter_subscription');
        }
    }

    setupForm(form, action) {
        if (!form) return;

        // Prevent duplicate event listeners
        if (form.dataset.recaptchaSetup === 'true') return;
        form.dataset.recaptchaSetup = 'true';

        form.addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleFormSubmit(form, action);
        });
    }

    async handleFormSubmit(form, action) {
        const submitButton = form.querySelector('input[type="submit"], button[type="submit"]');
        const originalText = submitButton ? submitButton.value || submitButton.textContent : '';

        // Prevent double submission
        if (form.dataset.submitting === 'true') {
            return;
        }

        try {
            // Mark form as submitting
            form.dataset.submitting = 'true';

            // Show loading state
            this.setButtonLoading(submitButton, 'Processing...');

            // Get reCAPTCHA token
            const token = await this.getRecaptchaToken(action);

            if (!token) {
                throw new Error('Failed to get reCAPTCHA token');
            }

            // Add token to form
            this.addTokenToForm(form, token);

            // Submit form
            form.submit();

        } catch (error) {
            this.handleRecaptchaError();
            this.setButtonLoading(submitButton, originalText);
            // Reset submitting flag on error
            form.dataset.submitting = 'false';
        }
    }

    async getRecaptchaToken(action) {
        if (!this.isLoaded || !window.grecaptcha) {
            throw new Error('reCAPTCHA not loaded');
        }

        return new Promise((resolve, reject) => {
            window.grecaptcha.ready(() => {
                window.grecaptcha.execute(this.siteKey, { action: action })
                    .then((token) => {
                        if (token) {
                            resolve(token);
                        } else {
                            reject(new Error('Empty token received'));
                        }
                    })
                    .catch((error) => {
                        reject(error);
                    });
            });
        });
    }

    addTokenToForm(form, token) {
        // Remove existing token inputs
        const existingTokens = form.querySelectorAll('input[name="g-recaptcha-response"], input[name="g-recaptcha-response-data"]');
        existingTokens.forEach(input => input.remove());

        // Add new token
        const tokenInput = document.createElement('input');
        tokenInput.type = 'hidden';
        tokenInput.name = 'g-recaptcha-response-data';
        tokenInput.value = token;
        form.appendChild(tokenInput);
    }

    setButtonLoading(button, text) {
        if (!button) return;

        if (button.tagName === 'INPUT') {
            button.value = text;
            button.disabled = true;
        } else {
            button.textContent = text;
            button.disabled = true;
        }
    }

    handleRecaptchaError() {
        // Show user-friendly error message
        this.showErrorMessage('reCAPTCHA verification failed. Please refresh the page and try again.');
    }

    showErrorMessage(message) {
        // Remove existing error messages
        const existingError = document.querySelector('.recaptcha-error');
        if (existingError) {
            existingError.remove();
        }

        // Create error message using DOM methods (CSP-compliant)
        const errorDiv = document.createElement('div');
        errorDiv.className = 'recaptcha-error bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-4';

        const flexDiv = document.createElement('div');
        flexDiv.className = 'flex';

        const iconDiv = document.createElement('div');
        iconDiv.className = 'flex-shrink-0';

        const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
        svg.setAttribute('class', 'h-5 w-5 text-red-400');
        svg.setAttribute('viewBox', '0 0 20 20');
        svg.setAttribute('fill', 'currentColor');

        const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
        path.setAttribute('fill-rule', 'evenodd');
        path.setAttribute('d', 'M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z');
        path.setAttribute('clip-rule', 'evenodd');

        svg.appendChild(path);
        iconDiv.appendChild(svg);

        const contentDiv = document.createElement('div');
        contentDiv.className = 'ml-3';

        const messageP = document.createElement('p');
        messageP.className = 'text-sm font-medium';
        messageP.textContent = message;

        contentDiv.appendChild(messageP);
        flexDiv.appendChild(iconDiv);
        flexDiv.appendChild(contentDiv);
        errorDiv.appendChild(flexDiv);

        // Insert error message at the top of the form
        const form = document.querySelector('form');
        if (form) {
            form.insertBefore(errorDiv, form.firstChild);
        }
    }
}

// Initialize only once to prevent duplicate handlers
if (!window.recaptchaHandlerInitialized) {
    window.recaptchaHandlerInitialized = true;

    const initializeRecaptcha = () => {
        // Only initialize if site key is available
        if (window.RECAPTCHA_SITE_KEY && window.RECAPTCHA_SITE_KEY.trim() !== '') {
            new RecaptchaHandler();
        } else {
            console.log('reCAPTCHA site key not available, skipping initialization');
        }
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initializeRecaptcha);
    } else {
        initializeRecaptcha();
    }
}