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
            console.warn('reCAPTCHA site key not found');
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
            console.error('Failed to load reCAPTCHA script');
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

        form.addEventListener('submit', (e) => {
            e.preventDefault();
            this.handleFormSubmit(form, action);
        });
    }

    async handleFormSubmit(form, action) {
        const submitButton = form.querySelector('input[type="submit"], button[type="submit"]');
        const originalText = submitButton ? submitButton.value || submitButton.textContent : '';

        try {
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
            console.error('reCAPTCHA error:', error);
            this.handleRecaptchaError();
            this.setButtonLoading(submitButton, originalText);
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

        // Log for debugging
        console.warn('reCAPTCHA verification failed - this may be due to network issues or browser compatibility');
    }

    showErrorMessage(message) {
        // Remove existing error messages
        const existingError = document.querySelector('.recaptcha-error');
        if (existingError) {
            existingError.remove();
        }

        // Create error message
        const errorDiv = document.createElement('div');
        errorDiv.className = 'recaptcha-error bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-4';
        errorDiv.innerHTML = `
      <div class="flex">
        <div class="flex-shrink-0">
          <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
          </svg>
        </div>
        <div class="ml-3">
          <p class="text-sm font-medium">${message}</p>
        </div>
      </div>
    `;

        // Insert error message at the top of the form
        const form = document.querySelector('form');
        if (form) {
            form.insertBefore(errorDiv, form.firstChild);
        }
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    new RecaptchaHandler();
});

// Also initialize if DOM is already loaded (for dynamic content)
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        new RecaptchaHandler();
    });
} else {
    new RecaptchaHandler();
}