// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "./controllers"
import "./admin_navigation"
import "./form_interactions"
import "./hero_animations"

// Global variable for package limit
let currentPackageLimit = 0;

// Global function to handle order contents toggle
function setupOrderContentsToggle() {
    console.log('Setting up order contents toggle...');

    // Handle order contents toggle
    document.querySelectorAll('.order-contents-toggle').forEach(button => {
        console.log('Found order contents toggle button:', button);

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
    console.log('Toggling order contents for order ID:', orderId);

    const details = document.querySelector(`.order-contents-details[data-order-id="${orderId}"]`);
    console.log('Found details element:', details);

    if (details) {
        if (details.classList.contains('hidden')) {
            details.classList.remove('hidden');
            // Add visual feedback to the button
            this.classList.add('bg-orange-100', 'text-orange-800');
            console.log('Order details shown');
        } else {
            details.classList.add('hidden');
            // Remove visual feedback from the button
            this.classList.remove('bg-orange-100', 'text-orange-800');
            console.log('Order details hidden');
        }
    } else {
        console.error('Could not find order details element for order ID:', orderId);
    }
}

// Package Modal Functionality
document.addEventListener('DOMContentLoaded', function () {
    setupPackageModal();
    setupOrderContentsToggle();
});

// Also handle Turbo navigation
document.addEventListener('turbo:load', function () {
    setupPackageModal();
    setupOrderContentsToggle();
});

// Also handle Turbo frame loads
document.addEventListener('turbo:frame-load', function () {
    setupOrderContentsToggle();
});

function setupPackageModal() {
    // Function to open package modal
    window.openPackageModal = function (packageId, packageLimit, products) {
        currentPackageLimit = packageLimit;

        // Set package ID in hidden field
        const packageIdField = document.getElementById('packageId');
        if (packageIdField) {
            packageIdField.value = packageId;
        }

        // Set package limit display
        const packageLimitDisplay = document.getElementById('packageLimit');
        if (packageLimitDisplay) {
            packageLimitDisplay.textContent = packageLimit;
        }

        // Clear and populate product selection container
        const container = document.getElementById('productSelectionContainer');
        if (container) {
            container.innerHTML = '';

            products.forEach(product => {
                const div = document.createElement('div');
                div.className = 'flex items-center space-x-3 p-3 border border-orange-200 rounded-lg bg-orange-50';

                // Product image
                let imageHtml = '';
                if (product.image_url) {
                    imageHtml = `<img src="${product.image_url}" alt="${product.name}" class="w-12 h-12 object-cover rounded-lg flex-shrink-0">`;
                } else {
                    imageHtml = `<div class="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center flex-shrink-0">
                         <span class="text-orange-600 font-medium text-xs">${product.name.charAt(0).toUpperCase()}</span>
                       </div>`;
                }

                // Product name
                const nameHtml = `<div class="flex-1 min-w-0">
                           <h4 class="font-semibold text-orange-950 text-sm truncate">${product.name}</h4>
                         </div>`;

                // Quantity controls with white icons on orange circles
                const quantityControls = `
          <div class="flex items-center space-x-2 flex-shrink-0">
            <button type="button" 
                    class="w-8 h-8 rounded-full bg-orange-600 text-white flex items-center justify-center hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-1 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                    onclick="changeQuantity(${product.id}, -1)"
                    id="minus-${product.id}">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4"></path>
              </svg>
            </button>
            <span class="w-10 text-center font-semibold text-orange-900 text-sm" id="quantity-${product.id}">0</span>
            <button type="button" 
                    class="w-8 h-8 rounded-full bg-orange-600 text-white flex items-center justify-center hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-1 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                    onclick="changeQuantity(${product.id}, 1)"
                    id="plus-${product.id}">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
              </svg>
            </button>
          </div>`;

                div.innerHTML = `
          ${imageHtml}
          ${nameHtml}
          ${quantityControls}
          <input type="hidden" name="product_quantities[${product.id}]" value="0" id="hidden-${product.id}">
        `;

                container.appendChild(div);
            });
        }

        // Show modal and prevent background scrolling
        const modal = document.getElementById('packageModal');
        if (modal) {
            modal.classList.remove('hidden');
            // Prevent body scroll when modal is open
            document.body.style.overflow = 'hidden';
            document.body.style.position = 'fixed';
            document.body.style.width = '100%';
        }

        updateTotalItems();
    };

    // Function to open admin package modal
    window.openAdminPackageModal = function (packageId, packageLimit, products) {
        currentPackageLimit = packageLimit;

        // Set package ID in hidden field
        const packageIdField = document.getElementById('packageId');
        if (packageIdField) {
            packageIdField.value = packageId;
        }

        // Set package limit display
        const packageLimitDisplay = document.getElementById('packageLimit');
        if (packageLimitDisplay) {
            packageLimitDisplay.textContent = packageLimit;
        }

        // Clear and populate product selection container
        const container = document.getElementById('productSelectionContainer');
        if (container) {
            container.innerHTML = '';

            products.forEach(product => {
                const div = document.createElement('div');
                div.className = 'flex items-center space-x-3 p-3 border border-orange-200 rounded-lg bg-orange-50';

                // Product image
                let imageHtml = '';
                if (product.image_url) {
                    imageHtml = `<img src="${product.image_url}" alt="${product.name}" class="w-12 h-12 object-cover rounded-lg flex-shrink-0">`;
                } else {
                    imageHtml = `<div class="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center flex-shrink-0">
                         <span class="text-orange-600 font-medium text-xs">${product.name.charAt(0).toUpperCase()}</span>
                       </div>`;
                }

                // Product name
                const nameHtml = `<div class="flex-1 min-w-0">
                           <h4 class="font-semibold text-orange-950 text-sm truncate">${product.name}</h4>
                         </div>`;

                // Quantity controls with white icons on orange circles
                const quantityControls = `
          <div class="flex items-center space-x-2 flex-shrink-0">
            <button type="button" 
                    class="w-8 h-8 rounded-full bg-orange-600 text-white flex items-center justify-center hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-1 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                    onclick="changeQuantity(${product.id}, -1)"
                    id="minus-${product.id}">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4"></path>
              </svg>
            </button>
            <span class="w-10 text-center font-semibold text-orange-900 text-sm" id="quantity-${product.id}">0</span>
            <button type="button" 
                    class="w-8 h-8 rounded-full bg-orange-600 text-white flex items-center justify-center hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-1 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                    onclick="changeQuantity(${product.id}, 1)"
                    id="plus-${product.id}">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
              </svg>
            </button>
          </div>`;

                div.innerHTML = `
          ${imageHtml}
          ${nameHtml}
          ${quantityControls}
          <input type="hidden" name="product_quantities[${product.id}]" value="0" id="hidden-${product.id}">
        `;

                container.appendChild(div);
            });
        }

        // Show modal and prevent background scrolling
        const modal = document.getElementById('adminPackageModal');
        if (modal) {
            modal.classList.remove('hidden');
            // Prevent body scroll when modal is open
            document.body.style.overflow = 'hidden';
            document.body.style.position = 'fixed';
            document.body.style.width = '100%';
        }

        updateTotalItems();
    };

    // Function to close package modal
    window.closePackageModal = function () {
        const modal = document.getElementById('packageModal');
        if (modal) {
            modal.classList.add('hidden');
            // Restore body scroll when modal is closed
            document.body.style.overflow = '';
            document.body.style.position = '';
            document.body.style.width = '';
        }
    };

    // Function to close admin package modal
    window.closeAdminPackageModal = function () {
        const modal = document.getElementById('adminPackageModal');
        if (modal) {
            modal.classList.add('hidden');
            // Restore body scroll when modal is closed
            document.body.style.overflow = '';
            document.body.style.position = '';
            document.body.style.width = '';
        }
    };

    // Function to change quantity
    window.changeQuantity = function (productId, change) {
        const quantityDisplay = document.getElementById(`quantity-${productId}`);
        const hiddenInput = document.getElementById(`hidden-${productId}`);
        const minusButton = document.getElementById(`minus-${productId}`);
        const plusButton = document.getElementById(`plus-${productId}`);

        if (!quantityDisplay || !hiddenInput) {
            console.error('Quantity elements not found for product:', productId);
            return;
        }

        const currentQuantity = parseInt(quantityDisplay.textContent) || 0;
        const newQuantity = currentQuantity + change;

        // Prevent going below 0
        if (newQuantity < 0) {
            return;
        }

        // Check if adding this would exceed the package limit
        const currentTotal = getCurrentTotal();

        if (change > 0 && (currentTotal + change) > currentPackageLimit) {
            // Show a subtle indication that the limit is reached
            const totalItemsDisplay = document.getElementById('totalItems');
            if (totalItemsDisplay) {
                totalItemsDisplay.classList.add('text-red-600', 'font-bold');
                setTimeout(() => {
                    totalItemsDisplay.classList.remove('text-red-600', 'font-bold');
                }, 1000);
            }
            return;
        }

        quantityDisplay.textContent = newQuantity;
        hiddenInput.value = newQuantity;

        // Update button states
        updateButtonStates();
        updateTotalItems();
    };

    // Function to get current total
    function getCurrentTotal() {
        const inputs = document.querySelectorAll('#productSelectionContainer input[type="hidden"]');
        return Array.from(inputs).reduce((sum, input) => sum + (parseInt(input.value) || 0), 0);
    }

    // Function to update button states
    function updateButtonStates() {
        const currentTotal = getCurrentTotal();
        const products = document.querySelectorAll('#productSelectionContainer [id^="quantity-"]');

        products.forEach(productElement => {
            const productId = productElement.id.replace('quantity-', '');
            const quantity = parseInt(productElement.textContent) || 0;
            const minusButton = document.getElementById(`minus-${productId}`);
            const plusButton = document.getElementById(`plus-${productId}`);

            // Disable minus button if quantity is 0
            if (minusButton) {
                minusButton.disabled = quantity <= 0;
            }

            // Disable plus button if adding would exceed limit
            if (plusButton) {
                const wouldExceed = currentTotal >= currentPackageLimit;
                plusButton.disabled = wouldExceed;
            }
        });
    }

    // Function to update total items
    window.updateTotalItems = function () {
        const inputs = document.querySelectorAll('#productSelectionContainer input[type="hidden"]');
        const total = Array.from(inputs).reduce((sum, input) => sum + (parseInt(input.value) || 0), 0);

        const totalItemsDisplay = document.getElementById('totalItems');
        if (totalItemsDisplay) {
            totalItemsDisplay.textContent = total;

            // Add visual feedback when limit is reached
            if (total >= currentPackageLimit) {
                totalItemsDisplay.classList.add('text-green-600', 'font-bold');
            } else {
                totalItemsDisplay.classList.remove('text-green-600', 'font-bold');
            }
        }

        // Disable submit button if total exceeds limit
        const submitButton = document.getElementById('submitButton');
        if (submitButton) {
            const shouldDisable = total > currentPackageLimit;
            submitButton.disabled = shouldDisable;
            submitButton.classList.toggle('opacity-50', shouldDisable);
            submitButton.classList.toggle('cursor-not-allowed', shouldDisable);
        }

        // Update button states
        updateButtonStates();
    };

    // Add form submission handler
    document.addEventListener('submit', function (e) {
        if (e.target.id === 'packageForm') {
            const total = getCurrentTotal();

            // Validate that at least one item is selected
            if (total === 0) {
                e.preventDefault();
                alert('Please select at least one item for your package.');
                return;
            }

            // Validate that total doesn't exceed limit
            if (total > currentPackageLimit) {
                e.preventDefault();
                alert(`You can only select up to ${currentPackageLimit} items for this package.`);
                return;
            }

            // Show loading state
            const submitButton = document.getElementById('submitButton');
            if (submitButton) {
                submitButton.disabled = true;
                submitButton.textContent = 'Adding to Cart...';
            }
        }
    });

    // Add event listeners for close buttons
    document.addEventListener('click', function (e) {
        if (e.target.matches('[data-action="package-modal#close"]') ||
            e.target.closest('[data-action="package-modal#close"]')) {
            // Only close if it's the customer modal, not the admin modal
            const modal = document.getElementById('packageModal');
            if (modal && !modal.classList.contains('hidden')) {
                closePackageModal();
            }
        }

        // Handle admin modal close buttons
        if (e.target.closest('#adminPackageModal button') &&
            (e.target.textContent === 'Cancel' || e.target.closest('button').textContent === 'Cancel')) {
            closeAdminPackageModal();
        }
    });

    // Add event listener for backdrop click
    document.addEventListener('click', function (e) {
        // Handle customer modal backdrop
        const customerModal = document.getElementById('packageModal');
        if (customerModal && !customerModal.classList.contains('hidden')) {
            // Check if click is on the backdrop (the first child div)
            if (e.target === customerModal.firstElementChild) {
                closePackageModal();
            }
        }

        // Handle admin modal backdrop
        const adminModal = document.getElementById('adminPackageModal');
        if (adminModal && !adminModal.classList.contains('hidden')) {
            // Check if click is on the backdrop (the first child div)
            if (e.target === adminModal.firstElementChild) {
                closeAdminPackageModal();
            }
        }
    });

    // Add event listeners for package selection buttons (for both customer and admin modals)
    document.addEventListener('click', function (e) {
        if (e.target.matches('[data-package-modal-package-id-param]') ||
            e.target.closest('[data-package-modal-package-id-param]')) {

            const button = e.target.matches('[data-package-modal-package-id-param]') ?
                e.target : e.target.closest('[data-package-modal-package-id-param]');

            e.preventDefault();

            const packageId = button.dataset.packageModalPackageIdParam;
            const packageLimit = parseInt(button.dataset.packageModalPackageLimitParam);

            // Safely parse JSON with error handling
            let products = [];
            try {
                const productsJson = button.dataset.packageModalProductsParam;
                products = JSON.parse(productsJson);
            } catch (error) {
                console.error('Error parsing products JSON:', error);
                alert('Error loading package data. Please try refreshing the page.');
                return;
            }

            // Check if we're on admin page and use admin modal
            if (window.location.pathname.includes('/admin/')) {
                openAdminPackageModal(packageId, packageLimit, products);
            } else {
                openPackageModal(packageId, packageLimit, products);
            }
        }
    });

    // Add keyboard event listener for Escape key
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            const customerModal = document.getElementById('packageModal');
            const adminModal = document.getElementById('adminPackageModal');

            if (customerModal && !customerModal.classList.contains('hidden')) {
                closePackageModal();
            } else if (adminModal && !adminModal.classList.contains('hidden')) {
                closeAdminPackageModal();
            }
        }
    });
}
