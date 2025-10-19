// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "./controllers"
import "./csp_safe_styles"
import "./admin_navigation"
import "./admin_tabs"
import "./admin_reviews"
import "./form_interactions"
import "./hero_animations"
import "./image_switcher"
import "./user_management"
import "./recaptcha_handler"
import "./event_handlers"
import "./analytics"
import "./recaptcha_config"
import "./mobile_navigation"
import "./content_blocks"
import "./holiday_package_form"
import "./admin_layout"
import "./admin_order_handlers"

console.log('Application.js loaded');

// Global variable for package limit
let currentPackageLimit = 0;

// OLD PACKAGE MODAL FUNCTIONS - REMOVED: Now handled by Stimulus controller
// These functions are no longer needed as the package modal is fully managed by Stimulus

// Global function to handle order contents toggle
function setupOrderContentsToggle() {
    // Handle order contents toggle
    document.querySelectorAll('.order-contents-toggle').forEach(button => {
        // Remove existing event listeners to prevent duplicates
        button.removeEventListener('click', handleOrderContentsToggle);

        // Add new event listener
        button.addEventListener('click', handleOrderContentsToggle);
    });
}

// Handler function for order contents toggle
function handleOrderContentsToggle(event) {
    event.preventDefault();
    event.stopPropagation();

    const orderId = this.getAttribute('data-order-id');
    const details = document.querySelector(`.order-contents-details[data-order-id="${orderId}"]`);

    if (details) {
        if (details.classList.contains('hidden')) {
            details.classList.remove('hidden');
            // Update button icon to show expanded state (up arrow) using DOM methods
            const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
            svg.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
            svg.setAttribute('class', 'h-4 w-4');
            svg.setAttribute('fill', 'none');
            svg.setAttribute('viewBox', '0 0 24 24');
            svg.setAttribute('stroke', 'currentColor');

            const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
            path.setAttribute('stroke-linecap', 'round');
            path.setAttribute('stroke-linejoin', 'round');
            path.setAttribute('stroke-width', '2');
            path.setAttribute('d', 'M5 15l7-7 7 7');

            svg.appendChild(path);
            this.innerHTML = '';
            this.appendChild(svg);
            // Add visual feedback to the button
            this.classList.add('bg-orange-100', 'text-orange-800');
        } else {
            details.classList.add('hidden');
            // Update button icon to show collapsed state (down arrow) using DOM methods
            const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
            svg.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
            svg.setAttribute('class', 'h-4 w-4');
            svg.setAttribute('fill', 'none');
            svg.setAttribute('viewBox', '0 0 24 24');
            svg.setAttribute('stroke', 'currentColor');

            const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
            path.setAttribute('stroke-linecap', 'round');
            path.setAttribute('stroke-linejoin', 'round');
            path.setAttribute('stroke-width', '2');
            path.setAttribute('d', 'M19 9l-7 7-7-7');

            svg.appendChild(path);
            this.innerHTML = '';
            this.appendChild(svg);
            // Remove visual feedback from the button
            this.classList.remove('bg-orange-100', 'text-orange-800');
        }
    } else {
        console.error('Could not find order details element for order ID:', orderId);
    }
}

// Package Modal Functionality - Now handled by Stimulus controller
document.addEventListener('DOMContentLoaded', function () {
    setupOrderContentsToggle();
});

// Also handle Turbo navigation
document.addEventListener('turbo:load', function () {
    setupOrderContentsToggle();
});

// Also handle Turbo frame loads
document.addEventListener('turbo:frame-load', function () {
    setupOrderContentsToggle();
});

// Package modal functionality is now handled by Stimulus controller

// All package modal functionality is now handled by the Stimulus controller

// Additional utility functions
window.copyToClipboard = function () {
    const input = document.getElementById('review-link-input');
    if (input) {
        input.select();
        input.setSelectionRange(0, 99999); // For mobile devices
        document.execCommand('copy');
        alert('Link copied to clipboard!');
    }
};

window.showDebugInfo = function () {
    const debugInfo = document.getElementById('debug-info');
    if (debugInfo) {
        debugInfo.classList.remove('debug-info-hidden');
    }
};

window.hideDebugInfo = function () {
    const debugInfo = document.getElementById('debug-info');
    if (debugInfo) {
        debugInfo.classList.add('debug-info-hidden');
    }
};

window.switchView = function (viewType) {
    const styledView = document.getElementById('styled-view');
    const codeView = document.getElementById('code-view');
    const styledBtn = document.getElementById('styled-view-btn');
    const codeBtn = document.getElementById('code-view-btn');

    if (viewType === 'styled') {
        if (styledView) styledView.classList.remove('hidden');
        if (codeView) codeView.classList.add('hidden');
        if (styledBtn) styledBtn.classList.add('bg-orange-600', 'text-white');
        if (codeBtn) codeBtn.classList.remove('bg-orange-600', 'text-white');
    } else if (viewType === 'code') {
        if (styledView) styledView.classList.add('hidden');
        if (codeView) codeView.classList.remove('hidden');
        if (styledBtn) styledBtn.classList.remove('bg-orange-600', 'text-white');
        if (codeBtn) codeBtn.classList.add('bg-orange-600', 'text-white');
    }
};

window.toggleBusinessHours = function (dayKey) {
    const closedCheckbox = document.getElementById(`company_business_hours_${dayKey}_closed`);
    const timeFields = document.querySelectorAll(`[data-day="${dayKey}"] input[type="time"]`);

    if (closedCheckbox && closedCheckbox.checked) {
        timeFields.forEach(field => {
            field.disabled = true;
            field.value = '';
        });
    } else {
        timeFields.forEach(field => {
            field.disabled = false;
        });
    }
};

window.fillCustomerDetails = function (email, fullName, phone, address) {
    // Fill in customer details in the form
    const emailField = document.querySelector('input[name*="email"]');
    const nameField = document.querySelector('input[name*="name"]');
    const phoneField = document.querySelector('input[name*="phone"]');
    const addressField = document.querySelector('input[name*="address"]');

    if (emailField) emailField.value = email;
    if (nameField) nameField.value = fullName;
    if (phoneField) phoneField.value = phone;
    if (addressField) addressField.value = address;
};

// Admin order management functions
window.addPackageToOrder = function () {
    // This function should be defined in the admin order view
    if (window.addPackageToOrderImpl) {
        window.addPackageToOrderImpl();
    }
};

window.removePackage = function (packageIndex) {
    // This function should be defined in the admin order view
    if (window.removePackageImpl) {
        window.removePackageImpl(packageIndex);
    }
};

window.removeIndividualProduct = function (productId) {
    // This function should be defined in the admin order view
    if (window.removeIndividualProductImpl) {
        window.removeIndividualProductImpl(productId);
    }
};

window.updateQuantity = function (productId) {
    // This function should be defined in the admin order view
    if (window.updateQuantityImpl) {
        window.updateQuantityImpl(productId);
    }
};
