// Admin Reviews Management - Handles approve, unapprove, toggle featured, and delete actions
class AdminReviews {
    constructor() {
        this.init();
    }

    init() {
        // Handle initial page load
        setTimeout(() => {
            this.setupReviewActions();
        }, 100);

        // Handle Turbo navigation
        document.addEventListener('turbo:render', () => {
            setTimeout(() => {
                this.setupReviewActions();
            }, 100);
        });
        document.addEventListener('turbo:load', () => {
            setTimeout(() => {
                this.setupReviewActions();
            }, 100);
        });
        document.addEventListener('turbo:frame-load', () => {
            setTimeout(() => {
                this.setupReviewActions();
            }, 100);
        });
    }

    setupReviewActions() {
        // Setup approve/unapprove buttons
        this.setupApproveButtons();

        // Setup featured toggle buttons
        this.setupFeaturedButtons();

        // Setup delete buttons
        this.setupDeleteButtons();

        // Setup expand row buttons
        this.setupExpandButtons();
    }

    setupApproveButtons() {
        // Remove existing event listeners
        document.querySelectorAll('.review-approve, .review-unapprove').forEach(button => {
            button.removeEventListener('click', this.handleApproveAction.bind(this));
        });

        // Add new event listeners
        document.querySelectorAll('.review-approve, .review-unapprove').forEach(button => {
            button.addEventListener('click', this.handleApproveAction.bind(this));
        });
    }

    setupFeaturedButtons() {
        console.log('Setting up featured buttons...');
        // Remove existing event listeners
        document.querySelectorAll('.review-feature, .review-unfeature').forEach(button => {
            console.log('Removing event listener from:', button);
            button.removeEventListener('click', this.handleFeaturedAction.bind(this));
        });

        // Add new event listeners
        const featuredButtons = document.querySelectorAll('.review-feature, .review-unfeature');
        console.log('Found featured buttons:', featuredButtons.length);
        featuredButtons.forEach((button, index) => {
            console.log(`Setting up featured button ${index}:`, button);
            button.addEventListener('click', this.handleFeaturedAction.bind(this));
        });
    }

    setupDeleteButtons() {
        // Remove existing event listeners
        document.querySelectorAll('.admin-action-btn-danger').forEach(button => {
            button.removeEventListener('click', this.handleDeleteAction.bind(this));
        });

        // Add new event listeners
        document.querySelectorAll('.admin-action-btn-danger').forEach(button => {
            button.addEventListener('click', this.handleDeleteAction.bind(this));
        });
    }

    setupExpandButtons() {
        console.log('Setting up expand buttons...');

        // Check if expandable rows exist
        const expandableRows = document.querySelectorAll('.review-expand-details');
        console.log('Found expandable rows:', expandableRows.length);
        expandableRows.forEach((row, index) => {
            console.log(`Expandable row ${index}:`, row);
            console.log(`Row data-review-id:`, row.dataset.reviewId);
            console.log(`Row classes:`, row.className);
            console.log(`Row collapsed state:`, row.classList.contains('review-row-collapsed'));
        });

        // Remove existing event listeners
        document.querySelectorAll('.review-expand-toggle').forEach(button => {
            console.log('Removing expand event listener from:', button);
            button.removeEventListener('click', this.handleExpandAction.bind(this));
        });

        // Add new event listeners
        const expandButtons = document.querySelectorAll('.review-expand-toggle');
        console.log('Found expand buttons:', expandButtons.length);
        expandButtons.forEach((button, index) => {
            console.log(`Setting up expand button ${index}:`, button);
            console.log(`Button data-review-id:`, button.dataset.reviewId);
            button.addEventListener('click', this.handleExpandAction.bind(this));
        });
    }

    handleExpandAction(event) {
        event.preventDefault();
        event.stopPropagation();

        const button = event.currentTarget;
        const reviewRow = button.closest('tr[data-review-id]');
        const reviewId = reviewRow.dataset.reviewId;

        console.log('Toggling expand for review ID:', reviewId);

        // Find the expandable row
        const expandableRow = document.querySelector(`.review-expand-details[data-review-id="${reviewId}"]`);

        if (expandableRow) {
            if (expandableRow.classList.contains('review-row-collapsed')) {
                // Show the expandable row
                expandableRow.classList.remove('review-row-collapsed');
                // Update button icon to show expanded state
                button.innerHTML = `
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7" />
                    </svg>
                `;
                // Add visual feedback
                button.classList.add('active');
                console.log('Review details expanded');
            } else {
                // Hide the expandable row
                expandableRow.classList.add('review-row-collapsed');
                // Update button icon to show collapsed state
                button.innerHTML = `
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                    </svg>
                `;
                // Remove visual feedback
                button.classList.remove('active');
                console.log('Review details collapsed');
            }
        } else {
            console.error('Could not find expandable row for review ID:', reviewId);
        }
    }

    async handleApproveAction(event) {
        event.preventDefault();
        event.stopPropagation();

        const button = event.currentTarget;
        const reviewRow = button.closest('tr[data-review-id]');
        const reviewId = reviewRow.dataset.reviewId;
        const isApproving = button.classList.contains('review-approve');
        const action = isApproving ? 'approve' : 'unapprove';
        const url = isApproving ?
            `/admin/reviews/${reviewId}/approve` :
            `/admin/reviews/${reviewId}/unapprove`;

        // Show loading state
        this.showLoadingState(button);

        try {
            const response = await fetch(url, {
                method: 'PATCH',
                headers: {
                    'X-CSRF-Token': this.getCSRFToken(),
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
            });

            const data = await response.json();

            if (data.success) {
                // Update the UI
                this.updateReviewRow(reviewRow, data.review);

                // Show success message
                this.showNotification(data.message, 'success');

                // Update stats if they exist
                this.updateStats();
            } else {
                this.showNotification(data.message || 'Action failed', 'error');
            }
        } catch (error) {
            console.error('Error performing approve action:', error);
            this.showNotification('An error occurred while processing your request', 'error');
        } finally {
            // Remove loading state
            this.removeLoadingState(button);
        }
    }

    async handleFeaturedAction(event) {
        event.preventDefault();
        event.stopPropagation();

        const button = event.currentTarget;
        const reviewRow = button.closest('tr[data-review-id]');
        const reviewId = reviewRow.dataset.reviewId;
        const url = `/admin/reviews/${reviewId}/toggle_featured`;

        // Show loading state
        this.showLoadingState(button);

        try {
            const response = await fetch(url, {
                method: 'PATCH',
                headers: {
                    'X-CSRF-Token': this.getCSRFToken(),
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
            });

            const data = await response.json();

            if (data.success) {
                // Update the UI
                this.updateReviewRow(reviewRow, data.review);

                // Show success message
                this.showNotification(data.message, 'success');

                // Update stats if they exist
                this.updateStats();
            } else {
                this.showNotification(data.message || 'Action failed', 'error');
            }
        } catch (error) {
            console.error('Error performing featured action:', error);
            this.showNotification('An error occurred while processing your request', 'error');
        } finally {
            // Remove loading state
            this.removeLoadingState(button);
        }
    }

    async handleDeleteAction(event) {
        event.preventDefault();
        event.stopPropagation();

        const button = event.currentTarget;
        const reviewRow = button.closest('tr[data-review-id]');
        const reviewId = reviewRow.dataset.reviewId;
        const url = `/admin/reviews/${reviewId}`;

        // Confirm deletion
        if (!confirm('Are you sure you want to delete this review? This action cannot be undone.')) {
            return;
        }

        // Show loading state
        this.showLoadingState(button);

        try {
            const response = await fetch(url, {
                method: 'DELETE',
                headers: {
                    'X-CSRF-Token': this.getCSRFToken(),
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                }
            });

            const data = await response.json();

            if (data.success) {
                // Hide the review row with animation
                this.hideReviewRow(reviewRow);

                // Show success message
                this.showNotification(data.message, 'success');

                // Update stats if they exist
                this.updateStats();

                // Update visible count
                this.updateVisibleCount();
            } else {
                this.showNotification(data.message || 'Delete failed', 'error');
            }
        } catch (error) {
            console.error('Error deleting review:', error);
            this.showNotification('An error occurred while deleting the review', 'error');
        } finally {
            // Remove loading state
            button.removeAttribute('data-loading');
        }
    }

    updateReviewRow(reviewRow, reviewData) {
        const reviewId = reviewRow.dataset.reviewId;

        // Update the row's data attributes
        reviewRow.dataset.status = reviewData.featured ? 'featured' : (reviewData.approved ? 'approved' : 'pending');

        // Update status badge
        const statusCell = reviewRow.querySelector('td:nth-child(3) .flex.flex-col');
        if (statusCell) {
            statusCell.innerHTML = reviewData.status_badge;
        }

        // Remove any existing featured styling - no more blue highlight
        reviewRow.classList.remove('bg-blue-50', 'border-l-4', 'border-blue-400');

        // Update action buttons
        this.updateActionButtons(reviewRow, reviewData);

        // Update preview row if it exists
        this.updatePreviewRow(reviewId, reviewData);

        // Update show page if we're on it
        this.updateShowPage(reviewData);
    }

    updateActionButtons(reviewRow, reviewData) {
        const actionsCell = reviewRow.querySelector('td:last-child .admin-action-btn-group');
        if (!actionsCell) return;

        // Store the delete button reference before removing others
        const deleteButton = actionsCell.querySelector('.admin-action-btn-danger');

        // Remove existing approve/unapprove and featured buttons
        actionsCell.querySelectorAll('.review-approve, .review-unapprove, .review-feature, .review-unfeature').forEach(btn => btn.remove());

        // Create new buttons
        const approveButton = this.createApproveButton(reviewData);
        const featuredButton = this.createFeaturedButton(reviewData);

        // Clear the actions cell and rebuild in correct order
        actionsCell.innerHTML = '';

        // Add buttons in the correct order: expand, show, approve, featured, delete
        // Expand button (down arrow)
        const expandButton = this.createExpandButton(reviewData.id);
        actionsCell.appendChild(expandButton);

        // Show button (eye icon)
        const showButton = this.createShowButton(reviewData.id);
        actionsCell.appendChild(showButton);

        // Approve button
        if (approveButton) {
            actionsCell.appendChild(approveButton);
        }

        // Featured button
        if (featuredButton) {
            actionsCell.appendChild(featuredButton);
        }

        // Delete button
        if (deleteButton) {
            actionsCell.appendChild(deleteButton);
        }

        // Re-setup event listeners for the new buttons
        this.setupReviewActions();
    }

    createExpandButton(reviewId) {
        const button = document.createElement('button');
        button.type = 'button';
        button.className = 'review-expand-toggle admin-action-btn';
        button.setAttribute('data-review-id', reviewId);
        button.title = 'Expand Review Details';
        button.innerHTML = `
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
            </svg>
        `;
        return button;
    }

    createShowButton(reviewId) {
        const button = document.createElement('a');
        button.href = `/admin/reviews/${reviewId}`;
        button.className = 'admin-action-btn';
        button.title = 'View Details';
        button.innerHTML = `
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
            </svg>
        `;
        return button;
    }

    createApproveButton(reviewData) {
        if (reviewData.approved) {
            return this.createButton(
                'unapprove',
                'Unapprove Review',
                'admin-action-btn review-unapprove',
                'M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z',
                `/admin/reviews/${reviewData.id}/unapprove`
            );
        } else {
            return this.createButton(
                'approve',
                'Approve Review',
                'admin-action-btn review-approve',
                'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z',
                `/admin/reviews/${reviewData.id}/approve`
            );
        }
    }

    createFeaturedButton(reviewData) {
        console.log('Creating featured button with data:', reviewData);

        if (reviewData.featured) {
            console.log('Review is featured, creating unfeature button');
            return this.createButton(
                'unfeature',
                'Remove from Featured',
                'admin-action-btn review-unfeature',
                'M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z',
                `/admin/reviews/${reviewData.id}/toggle_featured`
            );
        } else if (reviewData.can_be_featured) {
            console.log('Review can be featured, creating feature button');
            return this.createButton(
                'feature',
                'Add to Featured',
                'admin-action-btn review-feature',
                'M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z',
                `/admin/reviews/${reviewData.id}/toggle_featured`
            );
        } else {
            console.log('Review cannot be featured, creating disabled button');
            return this.createDisabledButton(
                'Review must be approved before it can be featured',
                'admin-action-btn review-disabled'
            );
        }
    }

    createButton(action, title, className, svgPath, url) {
        console.log(`Creating button: ${action} with URL: ${url}`);
        const button = document.createElement('a');
        button.href = url;
        button.className = className;
        button.title = title;

        // Use proper star icons for featured buttons
        if (action === 'feature' || action === 'unfeature') {
            if (action === 'feature') {
                // Outline star for not featured - using the same star path as review ratings
                button.innerHTML = `
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
                    </svg>
                `;
            } else {
                // Filled star for featured - using the same star path but filled
                button.innerHTML = `
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
                    </svg>
                `;
            }
        } else {
            // Use the provided SVG path for other buttons
            button.innerHTML = `
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="${svgPath}" />
                </svg>
            `;
        }

        console.log('Created button:', button);
        return button;
    }

    createDisabledButton(title, className) {
        console.log(`Creating disabled button: ${title}`);
        const button = document.createElement('span');
        button.className = className;
        button.title = title;
        button.innerHTML = `
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
            </svg>
        `;
        console.log('Created disabled button:', button);
        return button;
    }

    updatePreviewRow(reviewId, reviewData) {
        const previewRow = document.querySelector(`.review-expand-details[data-review-id="${reviewId}"]`);
        if (!previewRow) return;

        // Update featured badge in preview
        const featuredBadge = previewRow.querySelector('.bg-blue-100.text-blue-800');
        if (featuredBadge) {
            if (reviewData.featured) {
                featuredBadge.style.display = 'inline-flex';
            } else {
                featuredBadge.style.display = 'none';
            }
        }

        // Update status in the review details section
        const statusSpan = previewRow.querySelector('.text-orange-900 span');
        if (statusSpan) {
            if (reviewData.featured) {
                statusSpan.innerHTML = '<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">Featured</span>';
            } else if (reviewData.approved) {
                statusSpan.innerHTML = '<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">Approved</span>';
            } else {
                statusSpan.innerHTML = '<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">Pending</span>';
            }
        }

        // Update preview border color
        const previewContainer = previewRow.querySelector('.bg-white.rounded-lg.border-2');
        if (previewContainer) {
            previewContainer.classList.remove('border-green-300', 'border-orange-200');
            if (reviewData.approved && reviewData.featured) {
                previewContainer.classList.add('border-green-300');
            } else {
                previewContainer.classList.add('border-orange-200');
            }
        }
    }

    hideReviewRow(reviewRow) {
        // Add fade out animation
        reviewRow.style.transition = 'opacity 0.3s ease-out, height 0.3s ease-out';
        reviewRow.style.opacity = '0';
        reviewRow.style.height = '0';
        reviewRow.style.overflow = 'hidden';

        // Also hide the expandable row if it exists
        const reviewId = reviewRow.dataset.reviewId;
        const expandableRow = document.querySelector(`.review-expand-details[data-review-id="${reviewId}"]`);
        if (expandableRow) {
            expandableRow.style.transition = 'opacity 0.3s ease-out, height 0.3s ease-out';
            expandableRow.style.opacity = '0';
            expandableRow.style.height = '0';
            expandableRow.style.overflow = 'hidden';
        }

        // Remove the rows after animation
        setTimeout(() => {
            reviewRow.remove();
            if (expandableRow) expandableRow.remove();
        }, 300);
    }

    updateStats() {
        // This could be enhanced to update the stats cards at the top
        // For now, we'll just log that stats should be updated
        console.log('Stats should be updated');
    }

    updateVisibleCount() {
        const visibleCountSpan = document.getElementById('visible-count');
        const totalCountSpan = document.getElementById('total-count');

        if (visibleCountSpan && totalCountSpan) {
            const currentVisible = parseInt(visibleCountSpan.textContent) || 0;
            const currentTotal = parseInt(totalCountSpan.textContent) || 0;

            visibleCountSpan.textContent = Math.max(0, currentVisible - 1);
            totalCountSpan.textContent = Math.max(0, currentTotal - 1);
        }
    }

    showLoadingState(button) {
        const originalContent = button.innerHTML;
        button.dataset.originalContent = originalContent;
        button.dataset.loading = 'true';

        button.innerHTML = `
            <svg class="animate-spin h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
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
        button.removeAttribute('data-loading');
        button.disabled = false;
    }

    showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `fixed top-4 right-4 z-50 p-4 rounded-lg shadow-lg transition-all duration-300 transform translate-x-full`;

        // Set colors based on type
        switch (type) {
            case 'success':
                notification.className += ' bg-green-500 text-white';
                break;
            case 'error':
                notification.className += ' bg-red-500 text-white';
                break;
            case 'warning':
                notification.className += ' bg-yellow-500 text-white';
                break;
            default:
                notification.className += ' bg-blue-500 text-white';
        }

        notification.innerHTML = `
            <div class="flex items-center">
                <span class="mr-2">${message}</span>
                <button class="ml-4 text-white hover:text-gray-200" onclick="this.parentElement.parentElement.remove()">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
            </div>
        `;

        // Add to page
        document.body.appendChild(notification);

        // Animate in
        setTimeout(() => {
            notification.classList.remove('translate-x-full');
        }, 100);

        // Auto-remove after 5 seconds
        setTimeout(() => {
            if (notification.parentElement) {
                notification.classList.add('translate-x-full');
                setTimeout(() => {
                    if (notification.parentElement) {
                        notification.remove();
                    }
                }, 300);
            }
        }, 5000);
    }

    getCSRFToken() {
        return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') ||
            document.querySelector('input[name="authenticity_token"]')?.value;
    }

    updateShowPage(reviewData) {
        // Check if we're on the show page
        const showPageContainer = document.querySelector('[data-review-page="true"]');
        if (!showPageContainer) return;

        // Update status indicators
        this.updateShowPageStatus(reviewData);

        // Update action buttons
        this.updateShowPageActions(reviewData);

        // Update preview styling
        this.updateShowPagePreview(reviewData);
    }

    updateShowPageStatus(reviewData) {
        // Update the status display in the show page
        const statusContainer = document.querySelector('[data-review-page="true"] .bg-orange-50 .flex.items-center.justify-center');
        if (!statusContainer) return;

        let statusHtml = '';
        if (reviewData.featured) {
            statusHtml = `
                <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                    ✓ Would appear on homepage
                </span>
            `;
        } else if (reviewData.approved) {
            statusHtml = `
                <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                    ✓ Approved but not featured
                </span>
            `;
        } else {
            statusHtml = `
                <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                    ⚠ Pending approval
                </span>
            `;
        }

        const statusSpan = statusContainer.querySelector('.inline-flex');
        if (statusSpan) {
            statusSpan.outerHTML = statusHtml;
        }
    }

    updateShowPageActions(reviewData) {
        const actionsContainer = document.querySelector('[data-review-page="true"] .flex.justify-end.items-center.gap-3');
        if (!actionsContainer) return;

        // Clear existing buttons
        actionsContainer.innerHTML = '';

        // Add featured toggle button
        const featuredButton = document.createElement('a');
        featuredButton.href = `/admin/reviews/${reviewData.id}/toggle_featured`;
        featuredButton.className = `admin-btn-secondary ${reviewData.featured ? 'review-unfeature' : 'review-feature'}`;
        featuredButton.textContent = reviewData.featured ? 'Remove from Featured' : 'Add to Featured';
        actionsContainer.appendChild(featuredButton);

        // Add approve/unapprove button
        const approveButton = document.createElement('a');
        if (reviewData.approved) {
            approveButton.href = `/admin/reviews/${reviewData.id}/unapprove`;
            approveButton.className = 'admin-btn-secondary review-unapprove';
            approveButton.textContent = 'Unapprove Review';
        } else {
            approveButton.href = `/admin/reviews/${reviewData.id}/approve`;
            approveButton.className = 'admin-btn-primary review-approve';
            approveButton.textContent = 'Approve Review';
        }
        actionsContainer.appendChild(approveButton);

        // Re-setup event listeners
        this.setupReviewActions();
    }

    updateShowPagePreview(reviewData) {
        // Update the preview border color based on status
        const previewContainer = document.querySelector('[data-review-page="true"] .bg-white.p-6.rounded-lg');
        if (!previewContainer) return;

        // Remove existing border classes
        previewContainer.classList.remove('border-green-300', 'border-orange-200');

        // Add appropriate border class
        if (reviewData.approved && reviewData.featured) {
            previewContainer.classList.add('border-green-300');
        } else {
            previewContainer.classList.add('border-orange-200');
        }
    }
}

// Initialize admin reviews when the script loads
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM Content Loaded - Initializing AdminReviews');
    new AdminReviews();
});

// Also initialize on Turbo events
document.addEventListener('turbo:load', () => {
    console.log('Turbo Load - Initializing AdminReviews');
    new AdminReviews();
});

// Export for potential use in other scripts
window.AdminReviews = AdminReviews;
