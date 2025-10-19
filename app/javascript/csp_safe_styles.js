// CSP-Safe Style Utility
// This utility provides CSP-compliant ways to apply dynamic styles
// while maintaining compatibility with existing JavaScript patterns

class CSPSafeStyles {
    constructor() {
        this.styleSheet = null;
        this.init();
    }

    init() {
        // Create a stylesheet for dynamic styles
        this.styleSheet = document.createElement('style');
        this.styleSheet.setAttribute('nonce', document.querySelector('meta[name="csp-nonce"]')?.content || '');
        document.head.appendChild(this.styleSheet);
    }

    // Apply styles using CSS custom properties (CSP-compliant)
    setStyle(element, property, value) {
        if (element && element.style) {
            element.style.setProperty(property, value);
        }
    }

    // Apply multiple styles at once
    setStyles(element, styles) {
        if (element && element.style) {
            Object.entries(styles).forEach(([property, value]) => {
                element.style.setProperty(property, value);
            });
        }
    }

    // Apply Tailwind-like classes dynamically
    addClass(element, className) {
        if (element && element.classList) {
            element.classList.add(className);
        }
    }

    removeClass(element, className) {
        if (element && element.classList) {
            element.classList.remove(className);
        }
    }

    toggleClass(element, className) {
        if (element && element.classList) {
            element.classList.toggle(className);
        }
    }

    // Create dynamic CSS rules (CSP-compliant)
    addRule(selector, styles) {
        if (this.styleSheet) {
            const rule = `${selector} { ${Object.entries(styles).map(([prop, val]) => `${prop}: ${val}`).join('; ')} }`;
            this.styleSheet.textContent += rule;
        }
    }

    // Remove all dynamic rules
    clearRules() {
        if (this.styleSheet) {
            this.styleSheet.textContent = '';
        }
    }

    // Apply styles with CSS custom properties
    setCSSVar(element, varName, value) {
        if (element && element.style) {
            element.style.setProperty(`--${varName}`, value);
        }
    }

    // Get computed style value
    getStyle(element, property) {
        if (element) {
            return window.getComputedStyle(element).getPropertyValue(property);
        }
        return null;
    }
}

// Create global instance
window.cspSafeStyles = new CSPSafeStyles();

// Utility functions for common patterns
window.setStyle = (element, property, value) => window.cspSafeStyles.setStyle(element, property, value);
window.setStyles = (element, styles) => window.cspSafeStyles.setStyles(element, styles);
window.addClass = (element, className) => window.cspSafeStyles.addClass(element, className);
window.removeClass = (element, className) => window.cspSafeStyles.removeClass(element, className);
window.toggleClass = (element, className) => window.cspSafeStyles.toggleClass(element, className);
window.setCSSVar = (element, varName, value) => window.cspSafeStyles.setCSSVar(element, varName, value);

// Export for module usage
export default CSPSafeStyles;
