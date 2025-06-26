document.addEventListener('DOMContentLoaded', function () {
    const contentTypeSelect = document.getElementById('content_type_select');
    const contentFields = document.querySelectorAll('.content-type-field');
    const jsonTextarea = document.querySelector('#json_content textarea');
    const jsonStatus = document.getElementById('json-status');
    const formatBtn = document.getElementById('format-json-btn');

    console.log('Admin Content Blocks JS loaded');
    console.log('Content type select:', contentTypeSelect);
    console.log('Content fields found:', contentFields.length);
    console.log('JSON textarea:', jsonTextarea);

    function showContentField() {
        if (!contentTypeSelect) return;

        const selectedType = contentTypeSelect.value || 'text';
        console.log('Selected content type:', selectedType);

        // Hide all content fields first
        contentFields.forEach(field => {
            field.style.display = 'none';
            console.log('Hiding field:', field.id);
        });

        // Show the selected field
        const activeField = document.getElementById(selectedType + '_content');
        console.log('Looking for field:', selectedType + '_content');
        console.log('Active field found:', activeField);

        if (activeField) {
            activeField.style.display = 'block';
            console.log('Showing field:', activeField.id);
        } else {
            console.warn('Could not find content field for type:', selectedType);
        }

        // Update debug info
        updateDebugInfo();
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

    // Show debug function
    window.showDebugInfo = function () {
        const debugDiv = document.getElementById('debug-info');
        if (debugDiv) {
            debugDiv.style.display = 'block';
            updateDebugInfo();
        }
    };

    // JSON Validation and Status
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
        } else {
            jsonStatus.className = 'px-2 py-1 rounded text-xs font-medium bg-red-100 text-red-800';
            jsonStatus.textContent = '✗ Invalid';
            jsonStatus.title = result.message;
        }
    }

    // Format JSON
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

    // Event listeners
    if (contentTypeSelect) {
        contentTypeSelect.addEventListener('change', function () {
            console.log('Content type changed to:', this.value);
            showContentField();
        });
    }

    if (jsonTextarea) {
        jsonTextarea.addEventListener('input', updateJSONStatus);
        jsonTextarea.addEventListener('blur', updateJSONStatus);
    }

    if (formatBtn) {
        formatBtn.addEventListener('click', formatJSON);
    }

    // Company Values Toggle Event Listener
    const companyValuesToggle = document.getElementById('company-values-toggle');
    if (companyValuesToggle) {
        companyValuesToggle.addEventListener('click', toggleCompanyValuesInfo);
    }

    // Initialize - this is crucial
    console.log('Initializing content field display...');
    showContentField();
    updateJSONStatus();

    // Force show correct field after a small delay to ensure DOM is ready
    setTimeout(() => {
        console.log('Re-running showContentField after timeout...');
        showContentField();
    }, 100);

    // Also re-initialize when page becomes visible (for browser back/forward)
    document.addEventListener('visibilitychange', function () {
        if (!document.hidden) {
            setTimeout(showContentField, 50);
        }
    });

    // Re-initialize on window focus
    window.addEventListener('focus', function () {
        setTimeout(showContentField, 50);
    });
});

// Also handle Turbo navigation events
document.addEventListener('turbo:load', function () {
    console.log('Turbo load event - re-initializing content blocks');
    // Small delay to ensure DOM is ready
    setTimeout(() => {
        const event = new Event('DOMContentLoaded');
        document.dispatchEvent(event);
    }, 50);
});

// Global function to manually refresh content fields (can be called from anywhere)
window.refreshContentFields = function () {
    const event = new Event('DOMContentLoaded');
    document.dispatchEvent(event);
}; 