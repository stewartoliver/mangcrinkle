// Mobile Navigation functionality
document.addEventListener('DOMContentLoaded', function () {
    initializeMobileNavigation();
});

document.addEventListener('turbo:load', function () {
    initializeMobileNavigation();
});

function initializeMobileNavigation() {
    const mobileMenuButton = document.getElementById('mobile-menu-button');
    const mobileMenu = document.getElementById('mobile-menu');
    let isMenuOpen = false;

    if (mobileMenuButton && mobileMenu) {
        // Toggle menu on button click
        mobileMenuButton.addEventListener('click', function (e) {
            e.preventDefault();
            e.stopPropagation();

            if (isMenuOpen) {
                closeMenu();
            } else {
                openMenu();
            }
        });

        // Prevent menu from closing when clicking inside it
        mobileMenu.addEventListener('click', function (e) {
            e.stopPropagation();
        });

        // Close menu when clicking outside
        document.addEventListener('click', function (e) {
            if (isMenuOpen && !mobileMenuButton.contains(e.target) && !mobileMenu.contains(e.target)) {
                closeMenu();
            }
        });

        // Close menu on window resize
        window.addEventListener('resize', function () {
            if (window.innerWidth >= 640 && isMenuOpen) {
                closeMenu();
            }
        });

        function openMenu() {
            mobileMenu.classList.remove('hidden');
            mobileMenu.classList.add('mobile-menu-open');
            isMenuOpen = true;
        }

        function closeMenu() {
            mobileMenu.classList.add('mobile-menu-closing');
            setTimeout(() => {
                mobileMenu.classList.add('hidden');
                mobileMenu.classList.add('mobile-menu-closed');
            }, 200);
            isMenuOpen = false;
        }
    }
}
