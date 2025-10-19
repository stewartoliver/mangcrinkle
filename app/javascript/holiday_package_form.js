// Holiday Package Form JavaScript
class HolidayPackageForm {
    constructor() {
        this.holidayToggle = document.getElementById('holiday-toggle');
        this.holidaySection = document.getElementById('holiday-section');
        this.holidayCheckbox = document.getElementById('holiday_package_checkbox');
        this.holidayDates = document.getElementById('holiday-dates');
        this.holidayPresets = document.getElementById('holiday-presets');
        this.toggleIcon = document.getElementById('holiday-toggle-icon');

        this.holidayPresetsData = {
            christmas: {
                start: '2024-12-01',
                end: '2024-12-31'
            },
            valentines: {
                start: '2025-02-01',
                end: '2025-02-14'
            },
            easter: {
                start: '2025-03-15',
                end: '2025-04-20'
            },
            mothers: {
                start: '2025-05-01',
                end: '2025-05-11'
            }
        };

        this.init();
    }

    init() {
        this.bindEvents();
        this.initializeState();
        this.setupFormLogging();
    }

    bindEvents() {
        if (this.holidayToggle) {
            this.holidayToggle.addEventListener('click', () => this.toggleHolidaySection());
        }

        if (this.holidayCheckbox) {
            this.holidayCheckbox.addEventListener('change', () => this.handleHolidayCheckboxChange());
        }

        // Holiday preset buttons
        const presetButtons = document.querySelectorAll('.holiday-preset-btn');
        presetButtons.forEach(button => {
            button.addEventListener('click', (e) => {
                const preset = e.target.dataset.preset;
                this.handleHolidayPreset(preset);
            });
        });
    }

    toggleHolidaySection() {
        const isVisible = !this.holidaySection.classList.contains('hidden');

        if (isVisible) {
            this.holidaySection.classList.add('hidden');
            this.toggleIcon.classList.remove('chevron-rotated');
            this.toggleIcon.classList.add('chevron-normal');
        } else {
            this.holidaySection.classList.remove('hidden');
            this.toggleIcon.classList.remove('chevron-normal');
            this.toggleIcon.classList.add('chevron-rotated');
        }
    }

    handleHolidayCheckboxChange() {
        if (this.holidayCheckbox.checked) {
            this.holidayDates.classList.remove('hidden');
            this.holidayPresets.classList.remove('hidden');
        } else {
            this.holidayDates.classList.add('hidden');
            this.holidayPresets.classList.add('hidden');
        }
    }

    handleHolidayPreset(preset) {
        const presetData = this.holidayPresetsData[preset];
        if (presetData) {
            const startDateField = document.querySelector('input[name="crinkle_package[holiday_start_date]"]');
            const endDateField = document.querySelector('input[name="crinkle_package[holiday_end_date]"]');

            if (startDateField) startDateField.value = presetData.start;
            if (endDateField) endDateField.value = presetData.end;
        }
    }

    initializeState() {
        if (this.holidayCheckbox && this.holidayCheckbox.checked) {
            this.holidayDates.classList.remove('hidden');
            this.holidayPresets.classList.remove('hidden');
        }
    }

    setupFormLogging() {
        const form = document.querySelector('form');
        if (form) {
            form.addEventListener('submit', (e) => {
                // Log all form fields
                const formData = new FormData(form);
                for (let [key, value] of formData.entries()) {
                    console.log(`${key}:`, value);
                }
            });
        }
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', function () {
    new HolidayPackageForm();
});

// Also initialize on Turbo navigation events
document.addEventListener('turbo:load', function () {
    new HolidayPackageForm();
});

document.addEventListener('turbo:render', function () {
    new HolidayPackageForm();
});

// Fallback: Try to initialize after a short delay
setTimeout(function () {
    if (!document.querySelector('#holiday-toggle')) {
        console.log('HolidayPackageForm: holiday-toggle element still not found after timeout');
    } else {
        new HolidayPackageForm();
    }
}, 1000);
