// Simple Image Switcher - Works on both show and index pages

// Initialize show page image switcher
function initializeShowPageSwitcher() {
    const container = document.getElementById('productImageContainer');
    if (!container) {
        return;
    }

    const images = container.querySelectorAll('.product-image');
    const indicators = document.querySelectorAll('.image-indicator');

    if (images.length <= 1) {
        return;
    }

    let currentIndex = 0;

    // Function to update display
    function updateDisplay() {
        // Update images
        images.forEach((img, index) => {
            if (index === currentIndex) {
                img.style.opacity = '1';
                img.classList.remove('opacity-0');
                img.classList.add('opacity-100');
            } else {
                img.style.opacity = '0';
                img.classList.remove('opacity-100');
                img.classList.add('opacity-0');
            }
        });

        // Update indicators
        indicators.forEach((indicator, index) => {
            indicator.classList.remove('bg-orange-200', 'hover:bg-orange-400', 'bg-orange-600', 'hover:bg-orange-700');

            if (index === currentIndex) {
                indicator.classList.add('bg-orange-600', 'hover:bg-orange-700');
            } else {
                indicator.classList.add('bg-orange-200', 'hover:bg-orange-400');
            }
        });
    }

    // Set up indicator clicks
    indicators.forEach((indicator, index) => {
        indicator.addEventListener('click', function (e) {
            e.preventDefault();
            e.stopPropagation();
            currentIndex = index;
            updateDisplay();
        });
    });

    // Set up arrow buttons
    const prevButton = document.getElementById('prevButton');
    const nextButton = document.getElementById('nextButton');

    if (prevButton) {
        prevButton.addEventListener('click', function (e) {
            e.preventDefault();
            e.stopPropagation();
            currentIndex = currentIndex > 0 ? currentIndex - 1 : images.length - 1;
            updateDisplay();
        });
    }

    if (nextButton) {
        nextButton.addEventListener('click', function (e) {
            e.preventDefault();
            e.stopPropagation();
            currentIndex = currentIndex < images.length - 1 ? currentIndex + 1 : 0;
            updateDisplay();
        });
    }

    // Handle arrow visibility
    container.addEventListener('mouseenter', function () {
        const arrows = document.querySelectorAll('.image-arrow');
        arrows.forEach(arrow => arrow.style.opacity = '1');
    });

    container.addEventListener('mouseleave', function () {
        const arrows = document.querySelectorAll('.image-arrow');
        arrows.forEach(arrow => arrow.style.opacity = '0');
    });

    // Keyboard navigation
    document.addEventListener('keydown', function (e) {
        if (!container.offsetParent) return; // Check if container is visible

        if (e.key === 'ArrowLeft') {
            e.preventDefault();
            currentIndex = currentIndex > 0 ? currentIndex - 1 : images.length - 1;
            updateDisplay();
        } else if (e.key === 'ArrowRight') {
            e.preventDefault();
            currentIndex = currentIndex < images.length - 1 ? currentIndex + 1 : 0;
            updateDisplay();
        }
    });

    // Touch support
    let touchStartX = 0;
    container.addEventListener('touchstart', function (e) {
        touchStartX = e.changedTouches[0].screenX;
    });

    container.addEventListener('touchend', function (e) {
        const touchEndX = e.changedTouches[0].screenX;
        const difference = touchStartX - touchEndX;
        const threshold = 50;

        if (Math.abs(difference) > threshold) {
            if (difference > 0) {
                // Swipe left - next image
                currentIndex = currentIndex < images.length - 1 ? currentIndex + 1 : 0;
            } else {
                // Swipe right - previous image
                currentIndex = currentIndex > 0 ? currentIndex - 1 : images.length - 1;
            }
            updateDisplay();
        }
    });

    updateDisplay();
}

// Initialize index page image switchers
function initializeIndexPageSwitchers() {
    const productContainers = document.querySelectorAll('.product-card-image-container');

    productContainers.forEach((container) => {
        const images = container.querySelectorAll('.product-card-image');
        const indicators = container.querySelectorAll('.image-indicator');

        if (images.length <= 1) return;

        let currentIndex = 0;

        // Function to update this container's display
        function updateDisplay() {
            // Update images
            images.forEach((img, index) => {
                img.style.opacity = index === currentIndex ? '1' : '0';
            });

            // Update indicators
            indicators.forEach((indicator, index) => {
                indicator.classList.remove('bg-orange-200', 'hover:bg-orange-400', 'bg-orange-600', 'hover:bg-orange-700');

                if (index === currentIndex) {
                    indicator.classList.add('bg-orange-600', 'hover:bg-orange-700');
                } else {
                    indicator.classList.add('bg-orange-200', 'hover:bg-orange-400');
                }
            });
        }

        // Set up indicator clicks for this container
        indicators.forEach((indicator, index) => {
            indicator.addEventListener('click', function (e) {
                e.preventDefault();
                e.stopPropagation();
                currentIndex = index;
                updateDisplay();
            });
        });

        updateDisplay();
    });
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function () {
    initializeShowPageSwitcher();
    initializeIndexPageSwitchers();
});

// Also handle Turbo navigation
document.addEventListener('turbo:load', function () {
    initializeShowPageSwitcher();
    initializeIndexPageSwitchers();
});

// Keep global functions for backward compatibility (but they shouldn't be needed now)
window.selectImage = function (index) {
    // Legacy function - no longer needed
};

window.changeImage = function (direction) {
    // Legacy function - no longer needed
}; 