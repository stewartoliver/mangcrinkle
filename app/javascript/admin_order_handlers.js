// Admin Order Handlers - handles admin-specific functionality for order pages
// This works alongside the package-modal controller

// Global variables for admin order pages
window.selectedPackages = window.selectedPackages || [];
window.removedLineItemIds = window.removedLineItemIds || [];
window.updatedLineItems = window.updatedLineItems || [];
window.editingLineItemId = window.editingLineItemId || null;

// Admin Order Edit Page Specific Functions
window.updateNewItemsTotal = function () {
    let newItemsTotal = 0;

    // Calculate products total
    document.querySelectorAll('#add-items-section .product-quantity').forEach(input => {
        const quantity = parseInt(input.value) || 0;
        const price = parseFloat(input.dataset.productPrice);
        newItemsTotal += quantity * price;
    });

    // Calculate packages total
    window.selectedPackages.forEach(pkg => {
        newItemsTotal += pkg.price * pkg.quantity;
    });

    document.getElementById('new-items-total').textContent = '$' + newItemsTotal.toFixed(2);
    updateSelectedItemsDisplay();
};

// Admin Order New Page Specific Functions
window.updateOrderTotal = function () {
    let orderTotal = 0;

    // Calculate products total
    document.querySelectorAll('.product-quantity').forEach(input => {
        const quantity = parseInt(input.value) || 0;
        const price = parseFloat(input.dataset.productPrice);
        orderTotal += quantity * price;
    });

    // Calculate packages total
    window.selectedPackages.forEach(pkg => {
        orderTotal += pkg.price * pkg.quantity;
    });

    document.getElementById('order-total').textContent = '$' + orderTotal.toFixed(2);
    updateSelectedItemsDisplay();
};

// Update selected items display
window.updateSelectedItemsDisplay = function () {
    const displayDiv = document.getElementById('selected-items-display');
    const listDiv = document.getElementById('selected-items-list');
    const hasItems = window.selectedPackages.length > 0 || Array.from(document.querySelectorAll('.product-quantity, #add-items-section .product-quantity')).some(input => (parseInt(input.value) || 0) > 0);

    if (hasItems) {
        displayDiv.classList.remove('hidden');
        listDiv.innerHTML = '';

        // Create table structure
        const table = document.createElement('table');
        table.className = 'admin-table w-full';

        // Create table header
        const thead = document.createElement('thead');
        thead.className = 'admin-table-header';
        thead.innerHTML = `
      <tr>
        <th scope="col" class="admin-table-header-cell">Item</th>
        <th scope="col" class="admin-table-header-cell-center">Quantity</th>
        <th scope="col" class="admin-table-header-cell-center">Price</th>
        <th scope="col" class="admin-table-header-cell-center">Subtotal</th>
        <th scope="col" class="admin-table-header-cell-center">Actions</th>
      </tr>
    `;
        table.appendChild(thead);

        // Create table body
        const tbody = document.createElement('tbody');
        tbody.className = 'admin-table-body';

        // Add selected packages
        window.selectedPackages.forEach((pkg, index) => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
        <td class="admin-table-cell">
          <div class="text-sm font-medium text-orange-950">${pkg.name}</div>
          <div class="text-sm text-orange-600">(Package)</div>
          ${pkg.product_quantities && Object.keys(pkg.product_quantities).length > 0 ? `
            <div class="mt-2 text-xs text-orange-500">
              <div class="font-medium mb-1">Selected items:</div>
              ${Object.entries(pkg.product_quantities).map(([productId, productData]) => {
                const quantity = typeof productData === 'object' ? productData.quantity : productData;
                const productName = typeof productData === 'object' ? productData.name : `Product ${productId}`;
                if (quantity > 0) {
                    return `<div class="ml-2">• ${quantity}x ${productName}</div>`;
                }
                return '';
            }).join('')}
            </div>
          ` : ''}
        </td>
        <td class="admin-table-cell-center text-sm text-orange-600">${pkg.quantity}</td>
        <td class="admin-table-cell-center text-sm text-orange-600">$${pkg.price.toFixed(2)}</td>
        <td class="admin-table-cell-center text-sm text-orange-600">$${(pkg.price * pkg.quantity).toFixed(2)}</td>
        <td class="admin-table-cell-center">
          <button type="button" data-action="remove-package" data-package-index="${index}" class="text-red-600 hover:text-red-800">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </td>
      `;
            tbody.appendChild(tr);
        });

        // Add selected individual products
        document.querySelectorAll('.product-quantity, #add-items-section .product-quantity').forEach(input => {
            const quantity = parseInt(input.value) || 0;
            if (quantity > 0) {
                const productCard = input.closest('.bg-white');
                const productName = productCard.querySelector('h5, h6').textContent.trim();
                const productPrice = parseFloat(input.dataset.productPrice);

                const tr = document.createElement('tr');
                tr.innerHTML = `
          <td class="admin-table-cell">
            <div class="text-sm font-medium text-orange-950">${productName}</div>
            <div class="text-sm text-orange-600">(Individual Product)</div>
          </td>
          <td class="admin-table-cell-center text-sm text-orange-600">${quantity}</td>
          <td class="admin-table-cell-center text-sm text-orange-600">$${productPrice.toFixed(2)}</td>
          <td class="admin-table-cell-center text-sm text-orange-600">$${(productPrice * quantity).toFixed(2)}</td>
          <td class="admin-table-cell-center">
            <button type="button" data-action="remove-individual-product" data-product-id="${input.dataset.productId}" class="text-red-600 hover:text-red-800">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
              </svg>
            </button>
          </td>
        `;
                tbody.appendChild(tr);
            }
        });

        table.appendChild(tbody);
        listDiv.appendChild(table);
    } else {
        displayDiv.classList.add('hidden');
    }
};

// Function to add package to order (called from admin modal)
window.addPackageToOrderImpl = function () {
    const container = document.getElementById('productSelectionContainer')
    if (!container) {
        console.error('productSelectionContainer not found')
        return
    }

    // Get all hidden inputs that contain product quantities
    const inputs = container.querySelectorAll('input[type="hidden"][id^="hidden-"]')
    const productQuantities = {}
    let totalQuantity = 0

    inputs.forEach(input => {
        const quantity = parseInt(input.value) || 0
        if (quantity > 0) {
            const productId = input.id.replace('hidden-', '')
            const productCard = input.closest('.flex.items-center')
            const productNameElement = productCard ? productCard.querySelector('h4') : null
            const productName = productNameElement ? productNameElement.textContent.trim() : `Product ${productId}`

            productQuantities[productId] = {
                quantity: quantity,
                name: productName
            }
            totalQuantity += quantity
        }
    })

    if (totalQuantity > 0) {
        const packageIdElement = document.getElementById('packageId')
        const currentPackageId = packageIdElement ? packageIdElement.value : null

        // Find package details using the current package ID
        let packageButton = document.querySelector(`[data-admin-package-modal-package-id-param="${currentPackageId}"]`)

        // Try alternative selector in case of HTML encoding issues
        if (!packageButton) {
            const altButton = Array.from(document.querySelectorAll('button[data-admin-package-modal-package-id-param]')).find(btn =>
                btn.getAttribute('data-admin-package-modal-package-id-param') === currentPackageId
            )
            if (altButton) {
                packageButton = altButton
            }
        }

        if (packageButton) {
            const packageCard = packageButton.closest('.bg-white')
            const packageName = packageCard.querySelector('h5').textContent.trim()
            const priceElement = packageCard.querySelector('.text-2xl.font-bold')
            const packagePrice = parseFloat(priceElement.textContent.replace('$', '').trim())

            // Check if we're editing an existing line item
            const editingLineItemId = document.getElementById('editingLineItemId')
            const isEditing = editingLineItemId && editingLineItemId.value

            if (isEditing) {
                // Update existing line item
                updateExistingLineItem(editingLineItemId.value, packageName, packagePrice, productQuantities)
            } else {
                // Check if this package is already in selectedPackages to prevent duplicates
                const existingPackageIndex = window.selectedPackages.findIndex(pkg => pkg.id === currentPackageId)

                if (existingPackageIndex !== -1) {
                    // Update existing package instead of adding duplicate
                    window.selectedPackages[existingPackageIndex] = {
                        id: currentPackageId,
                        name: packageName,
                        price: packagePrice,
                        quantity: 1,
                        product_quantities: productQuantities
                    }
                } else {
                    // Add new package
                    window.selectedPackages.push({
                        id: currentPackageId,
                        name: packageName,
                        price: packagePrice,
                        quantity: 1,
                        product_quantities: productQuantities
                    })
                }
            }

            // Close modal and update totals
            if (typeof window.closeAdminPackageModal === 'function') {
                window.closeAdminPackageModal()
            }

            // Update totals based on page type
            if (window.location.pathname.includes('/edit')) {
                if (typeof window.updateNewItemsTotal === 'function') {
                    window.updateNewItemsTotal()
                }
            } else {
                if (typeof window.updateOrderTotal === 'function') {
                    window.updateOrderTotal()
                }
            }
        } else {
            console.error('Could not find package button for ID:', currentPackageId)
        }
    } else {
        alert('Please select at least one item for the package.')
    }
}

// Function to close admin package modal
window.closeAdminPackageModal = function () {
    const adminModal = document.getElementById('adminPackageModal');
    if (adminModal) {
        adminModal.classList.add('hidden');
        document.body.classList.remove('modal-body-overflow-hidden', 'modal-body-position-fixed', 'modal-body-width-full');
    }

    // Clear editing state
    const editingLineItemId = document.getElementById('editingLineItemId');
    if (editingLineItemId) {
        editingLineItemId.value = '';
    }
};

// Function to remove package from selected packages
window.removePackage = function (index) {
    window.selectedPackages.splice(index, 1);
    if (window.location.pathname.includes('/edit')) {
        if (typeof window.updateNewItemsTotal === 'function') {
            window.updateNewItemsTotal();
        }
    } else {
        if (typeof window.updateOrderTotal === 'function') {
            window.updateOrderTotal();
        }
    }
};

// Function to remove individual product
window.removeIndividualProduct = function (productId) {
    const selector = window.location.pathname.includes('/edit')
        ? `#add-items-section .product-quantity[data-product-id="${productId}"]`
        : `.product-quantity[data-product-id="${productId}"]`;

    const input = document.querySelector(selector);
    if (input) {
        input.value = 0;
        if (window.location.pathname.includes('/edit')) {
            if (typeof window.updateNewItemsTotal === 'function') {
                window.updateNewItemsTotal();
            }
        } else {
            if (typeof window.updateOrderTotal === 'function') {
                window.updateOrderTotal();
            }
        }
    }
};

// Function to update existing line item (edit page only)
window.updateExistingLineItem = function (lineItemId, packageName, packagePrice, productQuantities) {
    const lineItemRow = document.querySelector(`tr[data-line-item-id="${lineItemId}"]`);
    if (lineItemRow) {
        // Update the display in the table
        const nameCell = lineItemRow.querySelector('td:first-child');
        const quantityCell = lineItemRow.querySelector('td:nth-child(2)');
        const priceCell = lineItemRow.querySelector('td:nth-child(3)');
        const subtotalCell = lineItemRow.querySelector('td:nth-child(4)');

        if (nameCell) {
            nameCell.innerHTML = `
        <div class="text-sm font-medium text-orange-950">${packageName}</div>
        ${productQuantities && Object.keys(productQuantities).length > 0 ? `
          <div class="mt-2 text-xs text-orange-500">
            <div class="font-medium mb-1">Selected items:</div>
            ${Object.entries(productQuantities).map(([id, productData]) => {
                const quantity = typeof productData === 'object' ? productData.quantity : productData;
                const productName = typeof productData === 'object' ? productData.name : `Product ${id}`;
                if (quantity > 0) {
                    return `<div class="ml-2">• ${quantity}x ${productName}</div>`;
                }
                return '';
            }).join('')}
          </div>
        ` : ''}
      `;
        }

        if (quantityCell) {
            quantityCell.textContent = '1';
        }

        if (priceCell) {
            priceCell.textContent = '$' + packagePrice.toFixed(2);
        }

        if (subtotalCell) {
            subtotalCell.textContent = '$' + packagePrice.toFixed(2);
        }

        // Update the data attributes
        lineItemRow.dataset.lineItemProductQuantities = JSON.stringify(productQuantities);

        // Add to updated line items for form submission
        if (!window.updatedLineItems) window.updatedLineItems = [];

        // Remove any existing entry for this line item to avoid duplicates
        window.updatedLineItems = window.updatedLineItems.filter(item => item.line_item_id !== lineItemId);

        window.updatedLineItems.push({
            line_item_id: lineItemId,
            product_quantities: productQuantities
        });

        // Update the current order total
        if (typeof updateCurrentOrderTotal === 'function') {
            updateCurrentOrderTotal();
        }
    }
};

// Function to remove line item (edit page only)
window.removeLineItem = function (lineItemId) {
    if (confirm('Are you sure you want to remove this item from the order?')) {
        // Add to removed items list
        window.removedLineItemIds.push(lineItemId);

        // Remove from display - find the table row
        const lineItemRow = document.querySelector(`tr[data-line-item-id="${lineItemId}"]`);
        if (lineItemRow) {
            lineItemRow.remove();
        }

        // Update current total
        if (typeof updateCurrentOrderTotal === 'function') {
            updateCurrentOrderTotal();
        }
    }
};

// Function to update current order total (edit page only)
window.updateCurrentOrderTotal = function () {
    let currentTotal = 0;

    // Calculate from remaining visible line items in the table
    document.querySelectorAll('.admin-table-body .line-item-card').forEach(card => {
        const priceElement = card.querySelector('td:nth-child(4)'); // Subtotal column
        if (priceElement) {
            const price = parseFloat(priceElement.textContent.replace('$', ''));
            currentTotal += price;
        }
    });

    // Add new items total
    const newItemsTotalElement = document.getElementById('new-items-total');
    if (newItemsTotalElement) {
        const newItemsTotal = parseFloat(newItemsTotalElement.textContent.replace('$', '')) || 0;
        currentTotal += newItemsTotal;
    }

    const currentOrderTotalElement = document.getElementById('current-order-total');
    if (currentOrderTotalElement) {
        currentOrderTotalElement.textContent = '$' + currentTotal.toFixed(2);
    }
};

// Function to open package modal for editing existing packages (edit page only)
window.openPackageModalForEditing = function (packageId, lineItemId, productQuantitiesJson) {
    const productQuantities = productQuantitiesJson ? JSON.parse(productQuantitiesJson) : {};

    // Find the package button to get the same data
    const packageButton = document.querySelector(`[data-admin-package-modal-package-id-param="${packageId}"]`);
    if (!packageButton) return;

    const packageLimit = packageButton.dataset.adminPackageModalPackageLimitParam;
    const products = JSON.parse(packageButton.dataset.adminPackageModalProductsParam);

    // Set editing state
    const editingLineItemIdElement = document.getElementById('editingLineItemId');
    if (editingLineItemIdElement) {
        editingLineItemIdElement.value = lineItemId;
    }

    // Trigger the package modal controller to open
    const event = new CustomEvent('click', {
        detail: {
            currentTarget: packageButton
        }
    });

    // Find the package modal controller and trigger it
    const packageModalElement = document.querySelector('[data-controller*="admin-package-modal"]');
    if (packageModalElement && packageModalElement.adminPackageModalController) {
        packageModalElement.adminPackageModalController.open(event);

        // Set the existing quantities after a short delay
        setTimeout(() => {
            Object.entries(productQuantities).forEach(([productId, quantity]) => {
                const quantityElement = document.getElementById(`quantity-${productId}`);
                const hiddenInput = document.getElementById(`hidden-${productId}`);
                if (quantityElement && hiddenInput) {
                    quantityElement.textContent = quantity;
                    hiddenInput.value = quantity;
                }
            });

            // Update the total and button states
            if (typeof window.updateTotalItems === 'function') {
                window.updateTotalItems();
            }
        }, 100);
    }
};

// Admin Order Handlers
function initializeAdminOrderHandlers() {
    // Add event listeners for quantity changes
    document.addEventListener('change', function (e) {
        if (e.target.classList.contains('product-quantity')) {
            if (window.location.pathname.includes('/edit')) {
                if (typeof window.updateNewItemsTotal === 'function') {
                    window.updateNewItemsTotal()
                }
            } else {
                if (typeof window.updateOrderTotal === 'function') {
                    window.updateOrderTotal()
                }
            }
        }
    })

    // Handle line item card clicks for editing (edit page only)
    if (window.location.pathname.includes('/edit')) {
        document.addEventListener('click', function (e) {
            const lineItemCard = e.target.closest('.line-item-card');
            if (lineItemCard && !e.target.classList.contains('remove-line-item-btn')) {
                const lineItemType = lineItemCard.dataset.lineItemType;
                const purchasableId = lineItemCard.dataset.lineItemPurchasableId;

                if (lineItemType === 'CrinklePackage') {
                    // Open package modal for editing
                    openPackageModalForEditing(purchasableId, lineItemCard.dataset.lineItemId, lineItemCard.dataset.lineItemProductQuantities);
                } else if (lineItemType === 'Product') {
                    // For individual products, we could add quantity editing here
                    alert('Product editing functionality can be added here');
                }
            }
        });

        // Handle remove line item button clicks
        document.addEventListener('click', function (e) {
            if (e.target.classList.contains('remove-line-item-btn') || e.target.closest('.remove-line-item-btn')) {
                const button = e.target.classList.contains('remove-line-item-btn') ? e.target : e.target.closest('.remove-line-item-btn');
                const lineItemId = button.dataset.lineItemId;
                window.removeLineItem(lineItemId);
            }
        });
    }

    // Handle Add Items button clicks (show/hide add items section)
    document.addEventListener('click', function (e) {
        // Add Items button
        if (e.target.id === 'add-items-btn' || e.target.closest('#add-items-btn')) {
            const addItemsSection = document.getElementById('add-items-section');
            const addItemsBtn = document.getElementById('add-items-btn');
            if (addItemsSection && addItemsBtn) {
                addItemsSection.classList.remove('hidden');
                addItemsBtn.classList.add('display-none');
            }
        }

        // Hide Items button
        if (e.target.id === 'hide-items-btn' || e.target.closest('#hide-items-btn')) {
            const addItemsSection = document.getElementById('add-items-section');
            const addItemsBtn = document.getElementById('add-items-btn');
            if (addItemsSection && addItemsBtn) {
                addItemsSection.classList.add('hidden');
                addItemsBtn.classList.remove('display-none');
            }
        }
    });

    // Note: Modal submit button clicks are now handled by the admin-package-modal Stimulus controller

    // Handle remove package and individual product actions
    document.addEventListener('click', function (e) {
        if (e.target.dataset.action === 'remove-package') {
            const index = parseInt(e.target.dataset.packageIndex);
            window.removePackage(index);
        } else if (e.target.dataset.action === 'remove-individual-product') {
            const productId = e.target.dataset.productId;
            window.removeIndividualProduct(productId);
        }
    });

    // Add event listeners for quantity changes
    document.querySelectorAll('.product-quantity').forEach(input => {
        input.addEventListener('change', function () {
            if (window.location.pathname.includes('/new')) {
                window.updateOrderTotal();
            } else if (window.location.pathname.includes('/edit')) {
                window.updateNewItemsTotal();
            }
        });
    });

    // Customer search functionality (new page only)
    if (window.location.pathname.includes('/new')) {
        const searchBtn = document.getElementById('search-customer-btn');
        if (searchBtn) {
            searchBtn.addEventListener('click', function () {
                const email = document.getElementById('customer-email-search').value;
                if (!email) return;

                fetch(`/admin/users/search?email=${encodeURIComponent(email)}`)
                    .then(response => response.json())
                    .then(data => {
                        const resultsDiv = document.getElementById('customer-search-results');
                        resultsDiv.innerHTML = '';

                        if (data.customer) {
                            resultsDiv.innerHTML = `
                                <div class="bg-green-50 border border-green-200 rounded-lg p-3">
                                    <p class="text-sm text-green-800">
                                        <strong>Found customer:</strong> ${data.customer.full_name} (${data.customer.email})
                                    </p>
                                    <button type="button" class="mt-2 text-sm text-green-600 hover:text-green-800" 
                                            data-action="use-customer" 
                                            data-customer-data='{"email":"${data.customer.email}","full_name":"${data.customer.full_name}","phone":"${data.customer.phone}","address":"${data.customer.address}"}'>
                                        Use this customer
                                    </button>
                                </div>
                            `;
                        } else {
                            resultsDiv.innerHTML = `
                                <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-3">
                                    <p class="text-sm text-yellow-800">No customer found with this email. You can create a new customer below.</p>
                                </div>
                            `;
                        }

                        resultsDiv.classList.remove('hidden');
                    })
                    .catch(error => {
                        console.error('Error searching for customer:', error);
                    });
            });
        }

        // Fill customer details
        window.fillCustomerDetails = function (email, name, phone, address) {
            document.querySelector('input[name="order[email]"]').value = email;
            document.querySelector('input[name="order[customer_name]"]').value = name;
            document.querySelector('input[name="order[phone]"]').value = phone;
            document.querySelector('textarea[name="order[address]"]').value = address;
        };
    }

    // Form submission - add line items (only on order creation/edit pages)
    const orderForm = document.querySelector('form[action*="admin/orders"], form[action*="/admin/orders"]')

    if (orderForm) {
        // Only proceed if we're on order creation/edit pages, not the index page
        if (window.location.pathname.includes('/admin/orders/new') ||
            window.location.pathname.includes('/admin/orders/') && window.location.pathname.match(/\/admin\/orders\/\d+\/edit$/)) {

            // Remove existing event listener to prevent duplicates
            orderForm.removeEventListener('submit', orderForm._adminSubmitHandler)

            // Create and store the handler function
            orderForm._adminSubmitHandler = function (e) {
                e.preventDefault()

                const lineItemsContainer = document.getElementById('line-items-container')
                if (!lineItemsContainer) {
                    console.error('Line items container not found!')
                    alert('Error: Line items container not found. Please refresh the page.')
                    return
                }

                // Clear existing line items
                lineItemsContainer.innerHTML = '';

                let lineItemCount = 0;

                // Add hidden fields for removed line items (edit page only)
                if (window.location.pathname.includes('/edit') && window.removedLineItemIds && window.removedLineItemIds.length > 0) {
                    window.removedLineItemIds.forEach(lineItemId => {
                        const hiddenInput = document.createElement('input');
                        hiddenInput.type = 'hidden';
                        hiddenInput.name = 'removed_line_item_ids[]';
                        hiddenInput.value = lineItemId;
                        lineItemsContainer.appendChild(hiddenInput);
                    });
                }

                // Add hidden fields for updated line items (edit page only)
                if (window.location.pathname.includes('/edit') && window.updatedLineItems && window.updatedLineItems.length > 0) {
                    window.updatedLineItems.forEach((updatedItem, index) => {
                        const lineItemIdInput = document.createElement('input');
                        lineItemIdInput.type = 'hidden';
                        lineItemIdInput.name = 'updated_line_item_ids[]';
                        lineItemIdInput.value = updatedItem.line_item_id;
                        lineItemsContainer.appendChild(lineItemIdInput);

                        const productQuantitiesInput = document.createElement('input');
                        productQuantitiesInput.type = 'hidden';
                        productQuantitiesInput.name = `updated_line_item_quantities_${updatedItem.line_item_id}`;
                        productQuantitiesInput.value = JSON.stringify(updatedItem.product_quantities);
                        lineItemsContainer.appendChild(productQuantitiesInput);
                    });
                }

                // Add new product line items
                const productInputs = document.querySelectorAll('.product-quantity, #add-items-section .product-quantity')

                productInputs.forEach((input, index) => {
                    const quantity = parseInt(input.value) || 0
                    if (quantity > 0) {
                        const productId = input.dataset.productId

                        const hiddenInput = document.createElement('input')
                        hiddenInput.type = 'hidden'
                        hiddenInput.name = 'line_items[][product_id]'
                        hiddenInput.value = productId
                        lineItemsContainer.appendChild(hiddenInput)

                        const quantityInput = document.createElement('input')
                        quantityInput.type = 'hidden'
                        quantityInput.name = 'line_items[][quantity]'
                        quantityInput.value = quantity
                        lineItemsContainer.appendChild(quantityInput)

                        lineItemCount++
                    }
                })

                // Add new package line items
                if (window.selectedPackages && window.selectedPackages.length > 0) {
                    window.selectedPackages.forEach((pkg, index) => {
                        const packageIdInput = document.createElement('input')
                        packageIdInput.type = 'hidden'
                        packageIdInput.name = 'line_items[][package_id]'
                        packageIdInput.value = pkg.id
                        lineItemsContainer.appendChild(packageIdInput)

                        const quantityInput = document.createElement('input')
                        quantityInput.type = 'hidden'
                        quantityInput.name = 'line_items[][quantity]'
                        quantityInput.value = pkg.quantity
                        lineItemsContainer.appendChild(quantityInput)

                        // Convert product_quantities to Rails format (product_id: quantity)
                        const railsProductQuantities = {}
                        Object.entries(pkg.product_quantities).forEach(([productId, productData]) => {
                            const quantity = typeof productData === 'object' ? productData.quantity : productData
                            railsProductQuantities[productId] = quantity
                        })

                        const productQuantitiesInput = document.createElement('input')
                        productQuantitiesInput.type = 'hidden'
                        productQuantitiesInput.name = 'line_items[][product_quantities]'
                        productQuantitiesInput.value = JSON.stringify(railsProductQuantities)
                        lineItemsContainer.appendChild(productQuantitiesInput)

                        lineItemCount++
                    })
                }

                // Check if we have any items (new page only)
                if (window.location.pathname.includes('/new') && lineItemCount === 0) {
                    alert('Please add at least one item to the order before submitting.')
                    return
                }

                // Check if we have any items (edit page with no existing items)
                if (window.location.pathname.includes('/edit') && lineItemCount === 0 && !document.querySelector('.line-item-card')) {
                    alert('Please add at least one item to the order before submitting.')
                    return
                }

                // Submit the form
                try {
                    this.submit()
                } catch (error) {
                    console.error('Error submitting form:', error)
                }
            };

            // Add the event listener
            orderForm.addEventListener('submit', orderForm._adminSubmitHandler);
        }
    } else {
        console.log('Admin orders form not found - this is normal on non-order pages');
    }

    // Initialize order total
    if (window.location.pathname.includes('/new')) {
        window.updateOrderTotal();
    }
}

// Initialize on DOMContentLoaded
document.addEventListener('DOMContentLoaded', initializeAdminOrderHandlers);

// Initialize on Turbo navigation
document.addEventListener('turbo:load', initializeAdminOrderHandlers);

// Initialize on Turbo frame loads
document.addEventListener('turbo:frame-load', initializeAdminOrderHandlers);
