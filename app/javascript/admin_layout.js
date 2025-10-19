// Admin Layout JavaScript
class AdminLayout {
    constructor() {
        this.sidebar = document.getElementById('sidebar');
        this.mobileMenuOverlay = document.getElementById('mobile-menu-overlay');
        this.openSidebarBtn = document.getElementById('open-sidebar');
        this.closeSidebarBtn = document.getElementById('close-sidebar');
        this.userMenuButton = document.getElementById('user-menu-button');
        this.userMenuDropdown = document.getElementById('user-menu-dropdown');

        this.init();
    }

    init() {
        this.bindEvents();
        this.setupFlashMessages();
        this.handleResize();
    }

    bindEvents() {
        // Mobile sidebar toggle
        if (this.openSidebarBtn) {
            this.openSidebarBtn.addEventListener('click', () => this.openSidebar());
        }
        if (this.closeSidebarBtn) {
            this.closeSidebarBtn.addEventListener('click', () => this.closeSidebar());
        }
        if (this.mobileMenuOverlay) {
            this.mobileMenuOverlay.addEventListener('click', () => this.closeSidebar());
        }

        // User dropdown toggle
        if (this.userMenuButton) {
            this.userMenuButton.addEventListener('click', (e) => this.handleUserMenuClick(e));

            // Close dropdown when clicking outside
            document.addEventListener('click', (event) => this.handleOutsideClick(event));
        }

        // Window resize handler
        window.addEventListener('resize', () => this.handleResize());
    }

    openSidebar() {
        if (this.sidebar) {
            this.sidebar.classList.remove('-translate-x-full');
        }
        if (this.mobileMenuOverlay) {
            this.mobileMenuOverlay.classList.remove('hidden');
        }
        document.body.classList.add('modal-body-overflow-hidden');
    }

    closeSidebar() {
        if (this.sidebar) {
            this.sidebar.classList.add('-translate-x-full');
        }
        if (this.mobileMenuOverlay) {
            this.mobileMenuOverlay.classList.add('hidden');
        }
        document.body.classList.remove('modal-body-overflow-hidden');
    }

    handleUserMenuClick(e) {
        e.preventDefault();
        e.stopPropagation();

        const dropdown = document.getElementById('user-menu-dropdown');

        if (dropdown) {
            const isCurrentlyVisible = dropdown.classList.contains('dropdown-visible') && !dropdown.classList.contains('hidden');

            if (isCurrentlyVisible) {
                // Hide the dropdown
                dropdown.classList.add('hidden');
                dropdown.classList.remove('dropdown-visible');
                dropdown.classList.add('dropdown-hidden');
            } else {
                // Show the dropdown
                dropdown.classList.remove('hidden');
                dropdown.classList.remove('dropdown-hidden');
                dropdown.classList.add('dropdown-visible');
            }
        }
    }

    handleOutsideClick(event) {
        const dropdown = document.getElementById('user-menu-dropdown');
        if (dropdown && !this.userMenuButton.contains(event.target) && !dropdown.contains(event.target)) {
            dropdown.classList.add('hidden');
            dropdown.classList.add('dropdown-hidden');
        }
    }

    handleResize() {
        if (window.innerWidth >= 1024) {
            this.closeSidebar();
        }
    }

    setupFlashMessages() {
        // Auto-dismiss flash messages after 5 seconds
        const flashMessages = document.querySelectorAll('[role="alert"]');
        flashMessages.forEach((message) => {
            setTimeout(() => {
                message.classList.add('message-fading');
                setTimeout(() => {
                    if (message.parentNode) {
                        message.parentNode.removeChild(message);
                    }
                }, 500);
            }, 5000);
        });

        // Handle manual dismissal of flash messages
        const closeButtons = document.querySelectorAll('.flash-close-btn');
        closeButtons.forEach((button) => {
            button.addEventListener('click', () => {
                const message = button.closest('[role="alert"]');
                if (message) {
                    message.classList.add('message-fading');
                    setTimeout(() => {
                        if (message.parentNode) {
                            message.parentNode.removeChild(message);
                        }
                    }, 500);
                }
            });
        });
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', function () {
    new AdminLayout();
});

// Also initialize on Turbo navigation events
document.addEventListener('turbo:load', function () {
    new AdminLayout();
});

document.addEventListener('turbo:render', function () {
    new AdminLayout();
});
