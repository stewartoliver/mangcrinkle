// Event Handlers - Secure replacement for inline JavaScript
// This file replaces all onclick, onchange, and other inline event handlers

document.addEventListener('DOMContentLoaded', function () {
    // Initialize all event handlers
    setupModalHandlers();
    setupQuantityHandlers();
    setupFormHandlers();
    setupUtilityHandlers();
});

// Modal handlers
function setupModalHandlers() {
    // Package modal close buttons - REMOVED: Now handled by Stimulus
    // Package selection buttons - REMOVED: Now handled by Stimulus
}

// Quantity change handlers - REMOVED: Now handled by Stimulus
function setupQuantityHandlers() {
    // Package modal quantity changes are now handled by Stimulus controller
}

// Form handlers
function setupFormHandlers() {
    // Business hours toggle
    document.addEventListener('change', function (e) {
        if (e.target.matches('[data-action="toggle-business-hours"]')) {
            const dayKey = e.target.dataset.dayKey;
            if (window.toggleBusinessHours) {
                window.toggleBusinessHours(dayKey);
            }
        }
    });

    // Customer search and selection
    document.addEventListener('click', function (e) {
        if (e.target.matches('[data-action="use-customer"]')) {
            const customerData = JSON.parse(e.target.dataset.customerData);
            if (window.fillCustomerDetails) {
                window.fillCustomerDetails(customerData.email, customerData.full_name, customerData.phone, customerData.address);
            }
        }
    });
}

// Utility handlers
function setupUtilityHandlers() {
    // Copy to clipboard
    document.addEventListener('click', function (e) {
        if (e.target.matches('[data-action="copy-to-clipboard"]')) {
            if (window.copyToClipboard) {
                window.copyToClipboard();
            }
        }
    });

    // Debug info toggle
    document.addEventListener('click', function (e) {
        if (e.target.matches('[data-action="toggle-debug"]')) {
            const target = e.target.dataset.target;
            if (target) {
                // Toggle specific element
                const element = document.getElementById(target);
                if (element) {
                    element.classList.toggle('hidden');
                }
            } else {
                // Show general debug info
                if (window.showDebugInfo) {
                    window.showDebugInfo();
                }
            }
        }

        if (e.target.matches('[data-action="hide-debug"]')) {
            if (window.hideDebugInfo) {
                window.hideDebugInfo();
            }
        }
    });

    // View switcher
    document.addEventListener('click', function (e) {
        if (e.target.matches('[data-action="switch-view"]')) {
            const viewType = e.target.dataset.viewType;
            if (window.switchView) {
                window.switchView(viewType);
            }
        }
    });

    // Admin order management
    document.addEventListener('click', function (e) {
        // Removed add-package-to-order handler - now handled by admin_order_handlers.js
        if (e.target.matches('[data-action="remove-package"]')) {
            const packageIndex = e.target.dataset.packageIndex;
            if (window.removePackage) {
                window.removePackage(packageIndex);
            }
        }

        if (e.target.matches('[data-action="remove-individual-product"]')) {
            const productId = e.target.dataset.productId;
            if (window.removeIndividualProduct) {
                window.removeIndividualProduct(productId);
            }
        }
    });

    // Quantity update handlers
    document.addEventListener('change', function (e) {
        if (e.target.matches('[data-action="update-quantity"]')) {
            const productId = e.target.dataset.productId;
            if (window.updateQuantity) {
                window.updateQuantity(productId);
            }
        }
    });

    // Review item removal
    document.addEventListener('click', function (e) {
        if (e.target.matches('[data-action="remove-review-item"]')) {
            e.target.parentElement.parentElement.remove();
        }
    });
}

// Package selection handler - REMOVED: Now handled by Stimulus
// The package modal is now fully managed by the Stimulus controller

// Function implementations are defined in application.js

// Functions are defined in application.js and made globally available there
// This file only handles event delegation and calls the global functions
