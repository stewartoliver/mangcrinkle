// Admin Content Blocks JavaScript - Enhanced for Turbo compatibility
let contentBlocksInitialized = false;

// Main initialization function
function initializeContentBlocks() {
    console.log('Initializing Admin Content Blocks...');

    const contentTypeSelect = document.getElementById('content_type_select');
    const contentFields = document.querySelectorAll('.content-type-field');
    const jsonTextarea = document.querySelector('#json_content textarea');
    const jsonStatus = document.getElementById('json-status');
    const formatBtn = document.getElementById('format-json-btn');

    console.log('Elements found:', {
        contentTypeSelect: !!contentTypeSelect,
        contentFields: contentFields.length,
        jsonTextarea: !!jsonTextarea,
        jsonStatus: !!jsonStatus,
        formatBtn: !!formatBtn
    });

    if (!contentTypeSelect) {
        console.log('Content type select not found, skipping initialization');
        return;
    }

    // Remove existing event listeners to prevent duplicates
    cleanupEventListeners();

    // Content field visibility management
    function showContentField() {
        const selectedType = contentTypeSelect.value || 'text';
        console.log('Showing content field for type:', selectedType);

        // Hide all content fields first
        contentFields.forEach(field => {
            field.style.display = 'none';
        });

        // Show the selected field
        const activeField = document.getElementById(selectedType + '_content');
        if (activeField) {
            activeField.style.display = 'block';
            console.log('Showing field:', activeField.id);

            // Focus on the content input if it exists
            const contentInput = activeField.querySelector('textarea, input[type="text"], input[type="file"]');
            if (contentInput && selectedType !== 'image') {
                setTimeout(() => contentInput.focus(), 100);
            }
        } else {
            console.warn('Could not find content field for type:', selectedType);
        }

        updateDebugInfo();
    }

    // JSON validation and status
    function validateJSON(text) {
        if (!text.trim()) {
            return { valid: true, message: '' };
        }

        try {
            JSON.parse(text);
            return { valid: true, message: 'Valid JSON' };
        } catch (e) {
            return { valid: false, message: 'Invalid JSON: ' + e.message };
        }
    }

    function updateJSONStatus() {
        if (!jsonTextarea || !jsonStatus) return;

        const result = validateJSON(jsonTextarea.value);

        if (jsonTextarea.value.trim() === '') {
            jsonStatus.classList.add('hidden');
            return;
        }

        jsonStatus.classList.remove('hidden');

        if (result.valid) {
            jsonStatus.className = 'px-2 py-1 rounded text-xs font-medium bg-green-100 text-green-800';
            jsonStatus.textContent = '✓ Valid';
            jsonStatus.title = '';
        } else {
            jsonStatus.className = 'px-2 py-1 rounded text-xs font-medium bg-red-100 text-red-800';
            jsonStatus.textContent = '✗ Invalid';
            jsonStatus.title = result.message;
        }
    }

    // Format JSON function
    function formatJSON() {
        if (!jsonTextarea) return;

        try {
            const parsed = JSON.parse(jsonTextarea.value);
            jsonTextarea.value = JSON.stringify(parsed, null, 2);
            updateJSONStatus();
        } catch (e) {
            alert('Cannot format invalid JSON. Please fix syntax errors first.');
        }
    }

    // Company Values Toggle
    function toggleCompanyValuesInfo() {
        const toggle = document.getElementById('company-values-toggle');
        const content = document.getElementById('company-values-content');
        const chevron = document.getElementById('company-values-chevron');

        if (!toggle || !content || !chevron) return;

        const isHidden = content.classList.contains('hidden');

        if (isHidden) {
            content.classList.remove('hidden');
            chevron.style.transform = 'rotate(180deg)';
        } else {
            content.classList.add('hidden');
            chevron.style.transform = 'rotate(0deg)';
        }
    }

    // Debug function
    function updateDebugInfo() {
        const debugContent = document.getElementById('debug-content');
        if (!debugContent) return;

        const selectedType = contentTypeSelect ? contentTypeSelect.value : 'none';
        let debugHtml = '<strong>Selected Type:</strong> ' + selectedType + '<br>';
        debugHtml += '<strong>Available Fields:</strong><br>';

        contentFields.forEach(field => {
            const isVisible = field.style.display !== 'none';
            debugHtml += '- ' + field.id + ': ' + (isVisible ? 'VISIBLE' : 'HIDDEN') + '<br>';
        });

        debugContent.innerHTML = debugHtml;
    }

    // Event listener setup
    function setupEventListeners() {
        // Content type change handler
        if (contentTypeSelect) {
            contentTypeSelect.addEventListener('change', function (e) {
                console.log('Content type changed to:', this.value);
                showContentField();
            });
        }

        // JSON textarea handlers
        if (jsonTextarea) {
            jsonTextarea.addEventListener('input', updateJSONStatus);
            jsonTextarea.addEventListener('blur', updateJSONStatus);
        }

        // Format button handler
        if (formatBtn) {
            formatBtn.addEventListener('click', formatJSON);
        }

        // Company Values Toggle
        const companyValuesToggle = document.getElementById('company-values-toggle');
        if (companyValuesToggle) {
            companyValuesToggle.addEventListener('click', function (e) {
                e.preventDefault();
                toggleCompanyValuesInfo();
            });
        }

        // Form submission handler to prevent double submission
        const form = document.querySelector('form[action*="content_blocks"]');
        if (form) {
            form.addEventListener('submit', function (e) {
                const submitBtn = form.querySelector('input[type="submit"], button[type="submit"]');
                if (submitBtn) {
                    submitBtn.disabled = true;
                    submitBtn.textContent = 'Saving...';

                    // Re-enable after 3 seconds as failsafe
                    setTimeout(() => {
                        submitBtn.disabled = false;
                        submitBtn.textContent = submitBtn.textContent.replace('Saving...',
                            submitBtn.textContent.includes('Create') ? 'Create Content Block' : 'Update Content Block');
                    }, 3000);
                }
            });
        }
    }

    // Clean up function
    function cleanupEventListeners() {
        // Remove any existing listeners - this prevents duplicates
        if (contentTypeSelect) {
            contentTypeSelect.removeEventListener('change', showContentField);
        }
    }

    // Initialize everything
    setupEventListeners();

    // Show the correct field immediately
    showContentField();

    // Initialize JSON status
    updateJSONStatus();

    // Set flag to prevent re-initialization
    contentBlocksInitialized = true;

    console.log('Content blocks initialization complete');
}

// Global functions
window.showDebugInfo = function () {
    const debugDiv = document.getElementById('debug-info');
    if (debugDiv) {
        debugDiv.style.display = 'block';
        const debugContent = document.getElementById('debug-content');
        if (debugContent) {
            const contentTypeSelect = document.getElementById('content_type_select');
            const contentFields = document.querySelectorAll('.content-type-field');
            const selectedType = contentTypeSelect ? contentTypeSelect.value : 'none';

            let debugHtml = '<strong>Selected Type:</strong> ' + selectedType + '<br>';
            debugHtml += '<strong>Available Fields:</strong><br>';

            contentFields.forEach(field => {
                const isVisible = field.style.display !== 'none';
                debugHtml += '- ' + field.id + ': ' + (isVisible ? 'VISIBLE' : 'HIDDEN') + '<br>';
            });

            debugContent.innerHTML = debugHtml;
        }
    }
};

window.refreshContentFields = function () {
    console.log('Manual refresh triggered');
    contentBlocksInitialized = false;
    initializeContentBlocks();
};

// Event listeners for different loading scenarios
document.addEventListener('DOMContentLoaded', function () {
    console.log('DOMContentLoaded - initializing content blocks');
    initializeContentBlocks();
});

document.addEventListener('turbo:load', function () {
    console.log('Turbo:load - re-initializing content blocks');
    contentBlocksInitialized = false;
    // Small delay to ensure DOM is ready
    setTimeout(() => {
        initializeContentBlocks();
    }, 50);
});

document.addEventListener('turbo:frame-load', function () {
    console.log('Turbo:frame-load - checking for content blocks');
    if (!contentBlocksInitialized) {
        setTimeout(() => {
            initializeContentBlocks();
        }, 50);
    }
});

// Handle page visibility change (for browser back/forward)
document.addEventListener('visibilitychange', function () {
    if (!document.hidden && !contentBlocksInitialized) {
        setTimeout(() => {
            initializeContentBlocks();
        }, 100);
    }
});

// Handle window focus
window.addEventListener('focus', function () {
    if (!contentBlocksInitialized) {
        setTimeout(() => {
            initializeContentBlocks();
        }, 100);
    }
});

console.log('Admin Content Blocks JS loaded and ready'); 