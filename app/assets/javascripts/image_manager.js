class ImageManager {
    constructor(container, options = {}) {
        this.container = container;
        this.options = {
            maxImages: parseInt(options.maxImages) || 3,
            allowPrimary: options.allowPrimary !== false,
            fieldName: options.fieldName || 'images',
            primaryFieldName: options.primaryFieldName || 'primary_image_id',
            ...options
        };

        this.currentImages = [];
        this.newFiles = [];
        this.primaryImageId = null;

        console.log('ImageManager initialized with maxImages:', this.options.maxImages);
        this.init();
    }

    init() {
        this.render();
        this.attachEventListeners();
        this.loadExistingImages();
    }

    render() {
        this.container.innerHTML = `
      <div class="image-manager">
        <div class="image-manager-header">
          <h4 class="text-sm font-medium text-orange-700 mb-2">Product Images</h4>
          <p class="text-xs text-orange-600 mb-4">
            Upload up to ${this.options.maxImages} images. ${this.options.allowPrimary ? 'Select one as primary for listings.' : ''}
          </p>
        </div>
        
        <div class="image-manager-grid" id="imageGrid">
          <!-- Images will be rendered here -->
        </div>
        
        <div class="image-manager-upload" id="uploadArea" style="display: none;">
          <input type="file" 
                 id="imageInput" 
                 multiple 
                 accept="image/*" 
                 class="admin-file-input"
                 style="display: none;">
          <div class="upload-dropzone" id="dropzone">
            <div class="upload-content">
              <svg class="upload-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
              </svg>
              <p class="upload-text">Click to upload or drag and drop</p>
              <p class="upload-subtext">PNG, JPG, GIF up to 10MB</p>
            </div>
          </div>
        </div>
      </div>
    `;

        this.updateUploadVisibility();
    }

    attachEventListeners() {
        const imageInput = this.container.querySelector('#imageInput');
        const dropzone = this.container.querySelector('#dropzone');

        // File input change
        imageInput.addEventListener('change', (e) => {
            this.handleFileSelect(e.target.files);
        });

        // Dropzone click
        dropzone.addEventListener('click', () => {
            imageInput.click();
        });

        // Drag and drop
        dropzone.addEventListener('dragover', (e) => {
            e.preventDefault();
            dropzone.classList.add('drag-over');
        });

        dropzone.addEventListener('dragleave', () => {
            dropzone.classList.remove('drag-over');
        });

        dropzone.addEventListener('drop', (e) => {
            e.preventDefault();
            dropzone.classList.remove('drag-over');
            this.handleFileSelect(e.dataTransfer.files);
        });
    }

    loadExistingImages() {
        // This will be called from the Rails view to load existing images
        const existingImages = this.container.dataset.existingImages;
        console.log('Raw existing images data:', existingImages);

        if (existingImages) {
            try {
                const parsedData = JSON.parse(existingImages);
                console.log('Parsed existing images:', parsedData);

                this.currentImages = parsedData.map(imgData => {
                    console.log('Processing image data:', imgData);
                    return {
                        id: imgData.image.id,
                        url: imgData.image.url,
                        isNew: false
                    };
                });

                console.log('Processed current images:', this.currentImages);

                this.primaryImageId = this.container.dataset.primaryImageId;
                console.log('Primary image ID from dataset:', this.primaryImageId);

                console.log('Final state after loading existing images:', {
                    currentImagesCount: this.currentImages.length,
                    newFilesCount: this.newFiles.length,
                    primaryImageId: this.primaryImageId
                });

                this.renderImages();
            } catch (e) {
                console.error('Error parsing existing images:', e);
                console.error('Raw data that failed to parse:', existingImages);
            }
        } else {
            console.log('No existing images data found');
        }
    }

    handleFileSelect(files) {
        const fileArray = Array.from(files);
        const totalImages = this.currentImages.length + this.newFiles.length;
        const remainingSlots = this.options.maxImages - totalImages;

        console.log('File selection:', {
            selectedFiles: fileArray.length,
            currentImages: this.currentImages.length,
            newFiles: this.newFiles.length,
            totalImages: totalImages,
            maxImages: this.options.maxImages,
            remainingSlots: remainingSlots
        });

        if (fileArray.length > remainingSlots) {
            alert(`You can only upload ${remainingSlots} more image(s). Maximum ${this.options.maxImages} images allowed.`);
            return;
        }

        fileArray.forEach(file => {
            if (file.type.startsWith('image/')) {
                this.addNewFile(file);
            }
        });
    }

    addNewFile(file) {
        const fileObj = {
            id: `new_${Date.now()}_${Math.random()}`,
            file: file,
            url: URL.createObjectURL(file),
            isNew: true
        };

        console.log('Adding new file:', {
            fileName: file.name,
            fileId: fileObj.id,
            currentImagesCount: this.currentImages.length,
            newFilesCount: this.newFiles.length,
            primaryImageId: this.primaryImageId
        });

        this.newFiles.push(fileObj);

        console.log('After adding new file:', {
            currentImagesCount: this.currentImages.length,
            newFilesCount: this.newFiles.length,
            totalImages: this.currentImages.length + this.newFiles.length
        });

        this.renderImages();
        this.updateUploadVisibility();
    }

    removeImage(imageId, isNew = false) {
        if (isNew) {
            // Remove new file from memory
            this.newFiles = this.newFiles.filter(img => img.id !== imageId);

            // Reset primary if it was the removed image
            if (this.primaryImageId === imageId) {
                this.primaryImageId = null;
            }

            // Update UI immediately for new files
            this.renderImages();
            this.updateUploadVisibility();
        } else {
            // Remove existing image via AJAX - UI will be updated on success
            const productId = this.getProductId();
            if (productId) {
                this.removeExistingImage(productId, imageId);
            }
        }
    }

    getProductId() {
        // Try to get product ID from URL or form
        const pathParts = window.location.pathname.split('/');
        const productIndex = pathParts.indexOf('products');

        console.log('URL path parts:', pathParts);
        console.log('Product index:', productIndex);

        if (productIndex !== -1 && pathParts[productIndex + 1]) {
            const productId = pathParts[productIndex + 1];
            console.log('Extracted product ID:', productId);
            return productId;
        }

        // Try to get from form action as fallback
        const form = this.container.closest('form');
        if (form && form.action) {
            const actionMatch = form.action.match(/\/admin\/products\/(\d+)/);
            if (actionMatch) {
                const productId = actionMatch[1];
                console.log('Product ID from form action:', productId);
                return productId;
            }
        }

        console.error('Could not extract product ID from URL or form');
        return null;
    }

    async removeExistingImage(productId, imageId) {
        try {
            const url = `/admin/products/${productId}/remove_image`;
            console.log('Making DELETE request to:', url);
            console.log('Image ID:', imageId);

            const response = await fetch(url, {
                method: 'DELETE',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                },
                body: JSON.stringify({ image_id: imageId })
            });

            console.log('Response status:', response.status);
            console.log('Response ok:', response.ok);

            if (response.ok) {
                // Remove from current images array
                this.currentImages = this.currentImages.filter(img => img.id.toString() !== imageId.toString());

                // Reset primary if it was the removed image
                if (this.primaryImageId && this.primaryImageId.toString() === imageId.toString()) {
                    this.primaryImageId = null;
                }

                // Update UI after successful removal
                this.renderImages();
                this.updateUploadVisibility();

                console.log('Image removed successfully');
            } else {
                const errorText = await response.text();
                console.error('Server error:', errorText);
                alert('Failed to remove image. Please try again.');
            }
        } catch (error) {
            console.error('Error removing image:', error);
            alert('Error removing image. Please try again.');
        }
    }

    setPrimary(imageId) {
        if (this.options.allowPrimary) {
            // Convert to integer for existing images, keep as string for new images
            const allImages = [...this.currentImages, ...this.newFiles];
            const imageExists = allImages.some(img => img.id.toString() === imageId.toString());

            if (imageExists) {
                this.primaryImageId = imageId;
                this.renderImages();
            }
        }
    }

    renderImages() {
        const grid = this.container.querySelector('#imageGrid');
        const allImages = [...this.currentImages, ...this.newFiles];

        // Only auto-set primary image if we have no existing images and no primary is set
        if (allImages.length > 0 && !this.primaryImageId && this.currentImages.length === 0) {
            console.log('Auto-setting primary image for new images only');
            this.primaryImageId = allImages[0].id;
        }

        // Sort images to put primary first
        const sortedImages = this.sortImagesByPrimary(allImages);

        console.log('Rendering images:', {
            currentImages: this.currentImages.length,
            newFiles: this.newFiles.length,
            totalImages: allImages.length,
            primaryImageId: this.primaryImageId,
            sortedImages: sortedImages.length
        });

        grid.innerHTML = sortedImages.map(img => {
            // Defensive programming - ensure img and img.id exist
            if (!img || (!img.id && img.id !== 0)) {
                console.warn('Invalid image object:', img);
                return '';
            }

            const imageId = img.id.toString();
            const primaryId = this.primaryImageId ? this.primaryImageId.toString() : null;
            const isPrimary = primaryId && imageId === primaryId;

            return `
                <div class="image-item" data-image-id="${imageId}">
                    <div class="image-preview">
                        <img src="${img.url}" alt="Product image" class="image-thumbnail ${isPrimary ? 'primary-selected' : ''}">
                        <button type="button" class="remove-image" onclick="window.imageManager.removeImage('${imageId}', ${img.isNew || false})">
                            <svg fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"></path>
                            </svg>
                        </button>
                    </div>
                    
                    ${this.options.allowPrimary ? `
                        <button type="button" 
                                class="primary-toggle ${isPrimary ? 'selected' : ''}"
                                onclick="window.imageManager.setPrimary('${imageId}')">
                            <span class="primary-label">Primary</span>
                        </button>
                    ` : ''}
                </div>
            `;
        }).filter(html => html !== '').join('');
    }

    // Helper method to sort images with primary first
    sortImagesByPrimary(images) {
        if (!this.primaryImageId || images.length === 0) {
            return images;
        }

        const primaryId = this.primaryImageId.toString();
        const primaryImage = images.find(img => img.id.toString() === primaryId);
        const otherImages = images.filter(img => img.id.toString() !== primaryId);

        return primaryImage ? [primaryImage, ...otherImages] : images;
    }

    updateUploadVisibility() {
        const uploadArea = this.container.querySelector('#uploadArea');
        const totalImages = this.currentImages.length + this.newFiles.length;

        if (totalImages < this.options.maxImages) {
            uploadArea.style.display = 'block';
        } else {
            uploadArea.style.display = 'none';
        }
    }

    // Method to get form data for submission
    getFormData() {
        const formData = new FormData();

        // Add new files
        this.newFiles.forEach(fileObj => {
            formData.append(`${this.options.fieldName}[]`, fileObj.file);
        });

        // Add primary image ID
        if (this.options.allowPrimary && this.primaryImageId) {
            formData.append(this.options.primaryFieldName, this.primaryImageId);
        }

        return formData;
    }

    // Method to update hidden form fields
    updateHiddenFields() {
        // Remove existing hidden fields
        this.container.querySelectorAll('.image-manager-hidden').forEach(field => field.remove());

        // Also remove from form
        const form = this.container.closest('form');
        if (form) {
            form.querySelectorAll('.image-manager-hidden').forEach(field => field.remove());
        }

        // Add primary image field to the form
        if (this.options.allowPrimary && this.primaryImageId) {
            const primaryField = document.createElement('input');
            primaryField.type = 'hidden';
            primaryField.name = this.options.primaryFieldName;
            primaryField.value = this.primaryImageId;
            primaryField.className = 'image-manager-hidden';

            // Add to form instead of container
            if (form) {
                form.appendChild(primaryField);
            } else {
                this.container.appendChild(primaryField);
            }
        }
    }
} 