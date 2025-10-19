// Content Blocks Form JavaScript
// Handles content type switching and form functionality

function initializeContentBlockForm() {
    console.log('Initializing content block form...');

    const contentTypeSelect = document.getElementById('content_type_select');
    const contentFields = document.querySelectorAll('.content-type-field');
    const textTextarea = document.getElementById('content_block_text_content');
    const jsonTextarea = document.getElementById('content_block_json_content');
    const jsonStatus = document.getElementById('json-status');
    const formatBtn = document.getElementById('format-json-btn');

    console.log('Elements found:', {
        contentTypeSelect: !!contentTypeSelect,
        contentFields: contentFields.length,
        textTextarea: !!textTextarea,
        jsonTextarea: !!jsonTextarea,
        jsonStatus: !!jsonStatus,
        formatBtn: !!formatBtn
    });

    if (!contentTypeSelect) {
        console.log('Content type select not found');
        return;
    }

    // Content field visibility management
    function showContentField() {
        const selectedType = contentTypeSelect.value || 'text';
        console.log('Showing content field for type:', selectedType);

        // Hide all content fields first
        contentFields.forEach(field => {
            field.classList.add('content-field-hidden');
        });

        // Update form field names to ensure only the active field is submitted
        if (textTextarea) {
            textTextarea.name = selectedType === 'text' ? 'content_block[content]' : 'content_block[text_content_inactive]';
        }

        if (jsonTextarea) {
            jsonTextarea.name = selectedType === 'json' ? 'content_block[content]' : 'content_block[json_content_inactive]';
        }

        // Show the selected field
        const activeField = document.getElementById(selectedType + '_content');
        if (activeField) {
            activeField.classList.remove('content-field-hidden');
            activeField.classList.add('content-field-visible');
            console.log('Showing field:', activeField.id);

            // Focus on the appropriate content input
            if (selectedType === 'text' && textTextarea) {
                setTimeout(() => {
                    textTextarea.focus();
                }, 100);
            } else if (selectedType === 'json' && jsonTextarea) {
                setTimeout(() => {
                    jsonTextarea.focus();
                }, 100);
            }
        }
    }

    // JSON validation and formatting
    function validateJSON() {
        if (!jsonTextarea) return;

        const content = jsonTextarea.value.trim();
        if (!content) {
            jsonStatus.textContent = '';
            jsonStatus.className = '';
            return;
        }

        try {
            JSON.parse(content);
            jsonStatus.textContent = '✓ Valid JSON';
            jsonStatus.className = 'text-green-600 text-sm';
        } catch (error) {
            jsonStatus.textContent = '✗ Invalid JSON: ' + error.message;
            jsonStatus.className = 'text-red-600 text-sm';
        }
    }

    function formatJSON() {
        if (!jsonTextarea) return;

        const content = jsonTextarea.value.trim();
        if (!content) return;

        try {
            const parsed = JSON.parse(content);
            jsonTextarea.value = JSON.stringify(parsed, null, 2);
            validateJSON();
        } catch (error) {
            alert('Invalid JSON: ' + error.message);
        }
    }

    // Collapsible sections
    function toggleCollapsible(button) {
        const content = button.nextElementSibling;
        const chevron = button.querySelector('svg');

        if (!content || !chevron) return;

        const isHidden = content.classList.contains('hidden');

        if (isHidden) {
            content.classList.remove('hidden');
            chevron.classList.remove('chevron-normal');
            chevron.classList.add('chevron-rotated');
        } else {
            content.classList.add('hidden');
            chevron.classList.remove('chevron-rotated');
            chevron.classList.add('chevron-normal');
        }
    }

    // Set up event listeners
    if (contentTypeSelect) {
        contentTypeSelect.addEventListener('change', showContentField);
    }

    if (jsonTextarea) {
        jsonTextarea.addEventListener('input', validateJSON);
    }

    if (formatBtn) {
        formatBtn.addEventListener('click', formatJSON);
    }

    // Set up collapsible sections
    document.querySelectorAll('.collapsible-toggle').forEach(button => {
        button.addEventListener('click', function () {
            toggleCollapsible(this);
        });
    });

    // Initialize the form
    showContentField();
    validateJSON();
}

// Global debug function
window.showDebugInfo = function () {
    const debugDiv = document.getElementById('debug-info');
    if (debugDiv) {
        debugDiv.classList.remove('debug-info-hidden');
        const debugContent = document.getElementById('debug-content');
        if (debugContent) {
            const contentTypeSelect = document.getElementById('content_type_select');
            const contentFields = document.querySelectorAll('.content-type-field');
            const textTextarea = document.getElementById('content_block_text_content');

            const selectedType = contentTypeSelect ? contentTypeSelect.value : 'unknown';

            let debugHtml = '<strong>Selected Type:</strong> ' + selectedType + '<br>';
            debugHtml += '<strong>Available Fields:</strong><br>';

            contentFields.forEach(field => {
                const isVisible = !field.classList.contains('content-field-hidden');
                debugHtml += '- ' + field.id + ': ' + (isVisible ? 'VISIBLE' : 'HIDDEN') + '<br>';
            });

            debugHtml += '<br><strong>Content Textareas:</strong><br>';
            debugHtml += '- Text Content: ' + (textTextarea ? 'FOUND' : 'NOT FOUND');

            debugContent.innerHTML = debugHtml;
        }
    }
};

// Initialize on DOMContentLoaded
document.addEventListener('DOMContentLoaded', function () {
    console.log('Form script loading...');

    // Initialize immediately
    initializeContentBlockForm();

    // Also initialize on turbo events
    document.addEventListener('turbo:load', function () {
        console.log('Turbo load - reinitializing form...');
        setTimeout(() => initializeContentBlockForm(), 100);
    });
});
