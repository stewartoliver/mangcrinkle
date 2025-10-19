// User Management Tab Functionality
document.addEventListener('DOMContentLoaded', function () {
    initializeUserManagementTabs();
});

// Also handle Turbo navigation
document.addEventListener('turbo:load', function () {
    initializeUserManagementTabs();
});

function initializeUserManagementTabs() {
    const tabButtons = document.querySelectorAll('.tab-button');
    const userRows = document.querySelectorAll('.user-row');

    if (tabButtons.length === 0) return; // Exit if no tabs found

    tabButtons.forEach(button => {
        button.addEventListener('click', function () {
            const tab = this.dataset.tab;

            // Update active tab
            tabButtons.forEach(btn => btn.classList.remove('active'));
            this.classList.add('active');

            // Show/hide rows based on tab
            userRows.forEach(row => {
                const userType = row.dataset.userType;

                if (tab === 'all') {
                    row.classList.add('row-visible');
                } else if (tab === 'customers' && userType === 'customer') {
                    row.classList.add('row-visible');
                } else if (tab === 'admins' && userType === 'admin') {
                    row.classList.add('row-visible');
                } else {
                    row.classList.add('row-hidden');
                }
            });
        });
    });
} 