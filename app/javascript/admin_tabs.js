// Admin Tabs - Hybrid implementation supporting both client-side and server-side filtering
class AdminTabs {
    constructor() {
        this.init();
        this.isProcessingTab = false; // Flag to prevent multiple simultaneous tab clicks
    }

    init() {
        // Handle initial page load
        this.setupTabs();

        // Handle Turbo navigation - use turbo:render for better compatibility
        document.addEventListener('turbo:render', () => {
            this.setupTabs();
        });
        document.addEventListener('turbo:load', () => {
            this.setupTabs();
        });
        document.addEventListener('turbo:frame-load', () => {
            this.setupTabs();
        });

        // Handle browser back/forward
        window.addEventListener('popstate', () => {
            this.updateActiveTabFromURL();
        });
    }

    setupTabs() {
        // Find all tab containers on the page
        const containers = document.querySelectorAll('[data-tab-container]');

        containers.forEach(container => {
            this.setupContainer(container);
        });
    }

    setupContainer(container) {
        const containerType = container.dataset.tabContainer;
        const isPaginated = container.hasAttribute('data-paginated');

        // Setup tab buttons
        const tabButtons = container.querySelectorAll('.tab-button');

        tabButtons.forEach(button => {
            this.setupTabButton(button, containerType, isPaginated);
        });

        // Setup form sync if search form exists
        const searchForm = container.querySelector('form[id*="search"]');
        if (searchForm) {
            this.setupFormSync(searchForm, containerType);
        }

        // Update active tab based on current state
        this.updateActiveTabFromURL(containerType);

        // Initialize with current filter state
        this.initializeFilterState(container, containerType, isPaginated);
    }

    setupTabButton(button, containerType, isPaginated) {
        // Remove existing event listeners
        button.removeEventListener('click', this.handleTabClick.bind(this));

        // Add new event listener with proper binding
        const boundHandler = this.handleTabClick.bind(this);
        button.addEventListener('click', boundHandler);

        // Store the bound handler for cleanup
        button.dataset.boundHandler = boundHandler;
        button.dataset.containerType = containerType;
        button.dataset.isPaginated = isPaginated;
    }

    handleTabClick(event) {
        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation(); // Prevent other handlers from running

        // Prevent multiple simultaneous tab clicks
        if (this.isProcessingTab) {
            return;
        }

        const button = event.currentTarget;
        const containerType = button.dataset.containerType;
        const tabValue = button.dataset.tab;
        const isPaginated = button.dataset.isPaginated === 'true';

        if (!tabValue) {
            console.warn('Tab button missing data-tab attribute:', button);
            return;
        }

        // Set processing flag
        this.isProcessingTab = true;

        // Add loading state
        this.addLoadingState(button);

        try {
            if (isPaginated) {
                // Server-side filtering for paginated data
                this.handleServerSideTab(button, tabValue, containerType);
            } else {
                // Client-side filtering for small datasets
                this.handleClientSideTab(button, tabValue, containerType);
            }

            // Update URL without page reload
            this.updateURLWithoutReload(containerType, tabValue);

            // Update form filters to match
            this.syncFormWithTab(containerType, tabValue);

        } catch (error) {
            console.error('Error handling tab click:', error);
            this.removeLoadingState(button);
        } finally {
            // Reset processing flag
            this.isProcessingTab = false;
        }
    }

    handleServerSideTab(button, tabValue, containerType) {
        const container = button.closest('[data-tab-container]');
        if (!container) {
            console.error('Container not found for server-side tab filtering');
            this.removeLoadingState(button);
            return;
        }

        // Update active tab
        this.updateActiveTab(button);

        // Build the URL with the new tab filter
        const currentUrl = new URL(window.location);

        // Determine the parameter name based on container type
        let paramName = 'status';
        if (containerType === 'users') {
            paramName = 'tab';
        }

        // Check if we're already on the correct tab to prevent infinite loops
        const currentParam = currentUrl.searchParams.get(paramName);
        const isAlreadyCorrect = (currentParam === tabValue) || (!currentParam && tabValue === 'all');

        if (isAlreadyCorrect) {
            this.removeLoadingState(button);
            return;
        }

        // Remove existing parameter
        currentUrl.searchParams.delete(paramName);

        // Add new parameter if not "all"
        if (tabValue !== 'all') {
            currentUrl.searchParams.set(paramName, tabValue);
        }

        // Reset to first page when changing tabs
        currentUrl.searchParams.delete('page');

        // Navigate to the new URL (this will trigger a server request)
        window.location.href = currentUrl.toString();
    }

    handleClientSideTab(button, tabValue, containerType) {
        const container = button.closest('[data-tab-container]');
        if (!container) {
            console.error('Container not found for client-side tab filtering');
            this.removeLoadingState(button);
            return;
        }

        // Find only the main data rows, not expandable detail rows
        const mainRows = container.querySelectorAll('tbody tr:not(.order-contents-details):not(.message-details-row)');
        if (!mainRows || mainRows.length === 0) {
            console.warn('No main table rows found for filtering');
            this.removeLoadingState(button);
            return;
        }

        // Update active tab
        this.updateActiveTab(button);

        // Filter rows based on tab value
        let visibleCount = 0;
        mainRows.forEach((row, index) => {
            try {
                if (tabValue === 'all') {
                    row.style.display = '';
                    visibleCount++;

                    // Also show/hide the corresponding expandable row if it exists
                    this.toggleExpandableRow(row, true);
                } else {
                    // Determine which attribute to filter by
                    let rowValue = null;
                    switch (containerType) {
                        case 'products':
                            rowValue = row.dataset.category;
                            break;
                        case 'companies':
                            rowValue = row.dataset.status;
                            break;
                        case 'orders':
                            rowValue = row.dataset.status;
                            break;
                        case 'users':
                            rowValue = row.dataset.userType;
                            break;
                        case 'contact_messages':
                            rowValue = row.dataset.status;
                            break;
                        case 'dashboard_orders':
                            rowValue = row.dataset.status;
                            break;
                        case 'dashboard_messages':
                            rowValue = row.dataset.status;
                            break;
                        default:
                            rowValue = row.dataset.status || row.dataset.tab;
                    }

                    if (rowValue === tabValue) {
                        row.style.display = '';
                        visibleCount++;

                        // Show the corresponding expandable row
                        this.toggleExpandableRow(row, true);
                    } else {
                        row.style.display = 'none';

                        // Hide the corresponding expandable row
                        this.toggleExpandableRow(row, false);
                    }
                }
            } catch (error) {
                console.error('Error filtering row:', error, row);
                // Show the row if there's an error
                row.style.display = '';
                visibleCount++;
            }
        });

        // Update visible count display
        this.updateVisibleCount(container, visibleCount);

        // Remove loading state
        this.removeLoadingState(button);
    }

    toggleExpandableRow(mainRow, show) {
        // Find the corresponding expandable row
        const orderId = mainRow.dataset.orderId;
        const messageId = mainRow.dataset.messageId;

        if (orderId) {
            const expandableRow = document.querySelector(`.order-contents-details[data-order-id="${orderId}"]`);
            if (expandableRow) {
                expandableRow.style.display = show ? '' : 'none';
            }
        }

        if (messageId) {
            const expandableRow = document.querySelector(`.message-details-row[data-message-id="${messageId}"]`);
            if (expandableRow) {
                expandableRow.style.display = show ? '' : 'none';
            }
        }
    }

    updateVisibleCount(container, visibleCount) {
        // Find and update the visible count span
        const visibleCountSpan = container.querySelector('#visible-count') ||
            container.closest('.admin-container').querySelector('#visible-count');

        if (visibleCountSpan) {
            visibleCountSpan.textContent = visibleCount;
        }

        // Also update the filtered count span if it exists
        const filteredCountSpan = container.querySelector('#filtered-count') ||
            container.closest('.admin-container').querySelector('#filtered-count');

        if (filteredCountSpan) {
            filteredCountSpan.textContent = visibleCount;
        }

        // Show a message if no results are visible
        const noResultsMessage = container.querySelector('.no-results-message');
        if (visibleCount === 0) {
            if (!noResultsMessage) {
                this.showNoResultsMessage(container);
            }
        } else {
            if (noResultsMessage) {
                noResultsMessage.remove();
            }
        }
    }

    showNoResultsMessage(container) {
        const tbody = container.querySelector('tbody');
        if (!tbody) return;

        const noResultsRow = document.createElement('tr');
        noResultsRow.className = 'no-results-message';
        noResultsRow.innerHTML = `
            <td colspan="100%" class="px-6 py-8 text-center text-orange-600">
                <svg class="mx-auto h-12 w-12 text-orange-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <p class="text-lg font-medium">No results found</p>
                <p class="text-sm">Try selecting a different tab or clearing your filters.</p>
            </td>
        `;

        tbody.appendChild(noResultsRow);
    }

    updateURLWithoutReload(containerType, tabValue) {
        const currentUrl = new URL(window.location);

        // Determine the parameter name based on container type
        let paramName = 'status';
        if (containerType === 'users') {
            paramName = 'tab';
        }

        // Remove existing parameter
        currentUrl.searchParams.delete(paramName);

        // Add new parameter if not "all"
        if (tabValue !== 'all') {
            currentUrl.searchParams.set(paramName, tabValue);
        }

        // Reset to first page when changing tabs
        currentUrl.searchParams.delete('page');

        // Update URL without reload
        window.history.pushState({}, '', currentUrl.toString());
    }

    handlePaginationForFilteredResults(container, containerType, tabValue) {
        // Find pagination elements
        const paginationContainer = container.querySelector('.pagination') ||
            container.closest('.admin-container').querySelector('[class*="pagination"]');

        if (!paginationContainer) return;

        // Get visible rows count (only main rows, not expandable detail rows)
        const visibleRows = Array.from(container.querySelectorAll('tbody tr:not(.order-contents-details):not(.message-details-row)')).filter(row =>
            row.style.display !== 'none'
        );

        // Update pagination info if it exists
        const paginationInfo = paginationContainer.querySelector('[class*="text-sm"]');
        if (paginationInfo) {
            const totalVisible = visibleRows.length;
            paginationInfo.textContent = `Showing ${totalVisible} results`;
        }

        // Hide pagination if only one page of results
        if (visibleRows.length <= 25) { // Assuming 25 per page
            paginationContainer.style.display = 'none';
        } else {
            paginationContainer.style.display = '';
        }
    }

    updateActiveTab(clickedButton) {
        const container = clickedButton.closest('[data-tab-container]');
        const allButtons = container.querySelectorAll('.tab-button');

        allButtons.forEach(button => {
            button.classList.remove('active');
        });

        clickedButton.classList.add('active');
    }

    syncFormWithTab(containerType, tabValue) {
        const form = document.querySelector('form[id*="search"]');
        if (!form) return;

        switch (containerType) {
            case 'orders':
            case 'contact_messages':
                const statusSelect = form.querySelector('select[name="status"]');
                if (statusSelect) {
                    statusSelect.value = tabValue === 'all' ? '' : tabValue;
                }
                break;
            case 'users':
                const tabInput = form.querySelector('input[name="tab"]');
                if (tabInput) {
                    tabInput.value = tabValue === 'all' ? '' : tabValue;
                }
                break;
        }
    }

    setupFormSync(form, containerType) {
        form.addEventListener('submit', (event) => {
            try {
                // Update active tab based on form values
                this.syncFormWithTabs(form, containerType);
            } catch (error) {
                console.error('Error in form sync:', error);
            }
        });
    }

    syncFormWithTabs(form, containerType) {
        const container = form.closest('[data-tab-container]');
        const tabButtons = container.querySelectorAll('.tab-button');

        // Get form values
        let statusValue = '';
        let tabValue = '';

        switch (containerType) {
            case 'orders':
            case 'contact_messages':
                statusValue = form.querySelector('select[name="status"]')?.value || '';
                break;
            case 'users':
                tabValue = form.querySelector('input[name="tab"]')?.value || '';
                break;
        }

        // Update active tab based on form values
        tabButtons.forEach(button => {
            button.classList.remove('active');

            if (containerType === 'users') {
                if ((!tabValue && button.dataset.tab === 'all') ||
                    (tabValue === button.dataset.tab)) {
                    button.classList.add('active');
                }
            } else {
                if ((!statusValue && button.dataset.tab === 'all') ||
                    (statusValue === button.dataset.tab)) {
                    button.classList.add('active');
                }
            }
        });
    }

    updateActiveTabFromURL(containerType = null) {
        try {
            const urlParams = new URLSearchParams(window.location.search);
            const status = urlParams.get('status');
            const tab = urlParams.get('tab');

            // Find containers to update
            const containers = containerType ?
                [document.querySelector(`[data-tab-container="${containerType}"]`)] :
                document.querySelectorAll('[data-tab-container]');

            containers.forEach(container => {
                if (!container) return;

                const tabButtons = container.querySelectorAll('.tab-button');
                const containerType = container.dataset.tabContainer;

                tabButtons.forEach(button => {
                    button.classList.remove('active');

                    if (containerType === 'users') {
                        if ((!tab && button.dataset.tab === 'all') ||
                            (tab === button.dataset.tab)) {
                            button.classList.add('active');
                        }
                    } else {
                        if ((!status && button.dataset.tab === 'all') ||
                            (status === button.dataset.tab)) {
                            button.classList.add('active');
                        }
                    }
                });
            });
        } catch (error) {
            console.error('Error updating active tab from URL:', error);
        }
    }

    initializeFilterState(container, containerType, isPaginated) {
        // Apply initial filter based on URL parameters
        const urlParams = new URLSearchParams(window.location.search);
        const status = urlParams.get('status');
        const tab = urlParams.get('tab');

        if (status || tab) {
            const filterValue = status || tab;
            const tabButton = container.querySelector(`[data-tab="${filterValue}"]`);
            if (tabButton) {
                if (isPaginated) {
                    // For server-side filtering, just update the active state, don't navigate
                    this.updateActiveTab(tabButton);
                } else {
                    // For client-side filtering, we re-filter the rows
                    this.handleClientSideTab(tabButton, filterValue, containerType);
                }
            }
        }
    }

    addLoadingState(button) {
        const originalContent = button.innerHTML;
        button.dataset.originalContent = originalContent;

        button.innerHTML = `
            <svg class="animate-spin h-4 w-4 mx-auto" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
        `;
        button.disabled = true;
    }

    removeLoadingState(button) {
        const originalContent = button.dataset.originalContent;
        if (originalContent) {
            button.innerHTML = originalContent;
            button.removeAttribute('data-original-content');
        }
        button.disabled = false;
    }
}

// Initialize admin tabs when the script loads
document.addEventListener('DOMContentLoaded', () => {
    new AdminTabs();
});

// Export for potential use in other scripts
window.AdminTabs = AdminTabs;
