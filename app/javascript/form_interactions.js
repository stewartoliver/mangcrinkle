// Form Interactions Module
// Provides reusable functionality for form fields across the application

export class FormInteractions {
    constructor() {
        this.init();
    }

    init() {
        this.initDateFields();
        this.initSelectFields();
    }

    // Make date fields clickable anywhere to open date picker
    initDateFields() {
        document.querySelectorAll('.form-date').forEach(dateField => {
            dateField.addEventListener('click', (e) => {
                // Only trigger if not clicking on the calendar icon
                const rect = dateField.getBoundingClientRect();
                const clickX = e.clientX - rect.left;
                const fieldWidth = rect.width;

                // If click is not in the rightmost 30px (where the icon is), trigger the date picker
                if (clickX < fieldWidth - 30) {
                    dateField.showPicker();
                }
            });
        });
    }

    // Make select fields clickable anywhere to open dropdown
    initSelectFields() {
        document.querySelectorAll('.form-select').forEach(selectField => {
            selectField.addEventListener('click', (e) => {
                // Only trigger if not clicking on the dropdown icon
                const rect = selectField.getBoundingClientRect();
                const clickX = e.clientX - rect.left;
                const fieldWidth = rect.width;

                // If click is not in the rightmost 30px (where the icon is), trigger the dropdown
                if (clickX < fieldWidth - 30) {
                    selectField.focus();
                    // Create a click event to open the dropdown
                    const event = new MouseEvent('mousedown');
                    selectField.dispatchEvent(event);
                }
            });
        });
    }

    // Static method to initialize form interactions
    static init() {
        return new FormInteractions();
    }
}

// Auto-initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    FormInteractions.init();
}); 