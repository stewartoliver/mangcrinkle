// Admin Navigation JavaScript
document.addEventListener('DOMContentLoaded', function () {
    initializeAdminNavigation();
});

// Also handle Turbo navigation
document.addEventListener('turbo:load', function () {
    initializeAdminNavigation();
});

function initializeAdminNavigation() {
    const sidebar = document.getElementById('sidebar');
    const mobileMenuOverlay = document.getElementById('mobile-menu-overlay');
    const openSidebarBtn = document.getElementById('open-sidebar');
    const closeSidebarBtn = document.getElementById('close-sidebar');
    const userMenuButton = document.getElementById('user-menu-button');
    const userMenuDropdown = document.getElementById('user-menu-dropdown');

    // Mobile sidebar toggle
    function openSidebar() {
        if (sidebar) {
            sidebar.classList.remove('-translate-x-full');
        }
        if (mobileMenuOverlay) {
            mobileMenuOverlay.classList.remove('hidden');
        }
        document.body.style.overflow = 'hidden';
    }

    function closeSidebar() {
        if (sidebar) {
            sidebar.classList.add('-translate-x-full');
        }
        if (mobileMenuOverlay) {
            mobileMenuOverlay.classList.add('hidden');
        }
        document.body.style.overflow = '';
    }

    // Add event listeners for mobile sidebar
    if (openSidebarBtn) {
        openSidebarBtn.addEventListener('click', openSidebar);
    }
    if (closeSidebarBtn) {
        closeSidebarBtn.addEventListener('click', closeSidebar);
    }
    if (mobileMenuOverlay) {
        mobileMenuOverlay.addEventListener('click', closeSidebar);
    }

    // User dropdown toggle
    if (userMenuButton && userMenuDropdown) {
        userMenuButton.addEventListener('click', function (e) {
            e.preventDefault();
            e.stopPropagation();
            userMenuDropdown.classList.toggle('hidden');
        });

        // Close dropdown when clicking outside
        document.addEventListener('click', function (event) {
            if (!userMenuButton.contains(event.target) && !userMenuDropdown.contains(event.target)) {
                userMenuDropdown.classList.add('hidden');
            }
        });
    }

    // Close sidebar on window resize if mobile
    window.addEventListener('resize', function () {
        if (window.innerWidth >= 1024) {
            closeSidebar();
        }
    });
} 