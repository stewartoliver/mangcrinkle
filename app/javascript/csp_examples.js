// Example usage of CSP-Safe Styles Utility
// This shows how to use the utility with your existing JavaScript patterns

// Example 1: Using the utility functions
document.addEventListener('DOMContentLoaded', function () {
    // Instead of: element.style.opacity = '0.5';
    // Use: setStyle(element, 'opacity', '0.5');

    // Instead of: element.style.display = 'none';
    // Use: setStyle(element, 'display', 'none');

    // Instead of: element.style.transform = 'rotate(45deg)';
    // Use: setStyle(element, 'transform', 'rotate(45deg)');

    // Multiple styles at once
    // setStyles(element, {
    //     'opacity': '0.5',
    //     'transform': 'scale(1.2)',
    //     'background-color': '#ff0000'
    // });

    // CSS custom properties (recommended for dynamic values)
    // setCSSVar(element, 'rotation', '45deg');
    // setCSSVar(element, 'scale', '1.2');
});

// Example 2: Using with Tailwind classes
function toggleElement(element) {
    // Instead of: element.style.display = element.style.display === 'none' ? 'block' : 'none';
    // Use: toggleClass(element, 'hidden');

    // Instead of: element.style.opacity = '0.5';
    // Use: addClass(element, 'opacity-50');
}

// Example 3: Dynamic styles with CSS custom properties
function animateElement(element, duration, delay) {
    // Set CSS custom properties
    setCSSVar(element, 'animation-duration', `${duration}s`);
    setCSSVar(element, 'animation-delay', `${delay}s`);

    // Add animation class
    addClass(element, 'animate-pulse');
}

// Example 4: Creating dynamic CSS rules
function createDynamicRule(selector, styles) {
    // This creates a CSS rule that can be reused
    cspSafeStyles.addRule(selector, styles);
}

// Example 5: Using with existing JavaScript patterns
function updateProgressBar(progressElement, percentage) {
    // Instead of: progressElement.style.width = `${percentage}%`;
    // Use: setStyle(progressElement, 'width', `${percentage}%`);

    // Or use CSS custom properties
    setCSSVar(progressElement, 'progress-width', `${percentage}%`);
}

// Example 6: Chart/Graph styling (for your analytics issue)
function updateChart(chartElement, data) {
    // Instead of inline styles, use CSS custom properties
    setCSSVar(chartElement, 'chart-height', `${data.height}px`);
    setCSSVar(chartElement, 'chart-width', `${data.width}px`);

    // Add Tailwind classes for styling
    addClass(chartElement, 'bg-blue-500');
    addClass(chartElement, 'rounded-lg');
}

// Export for use in other files
window.CSPExamples = {
    toggleElement,
    animateElement,
    updateProgressBar,
    updateChart
};
