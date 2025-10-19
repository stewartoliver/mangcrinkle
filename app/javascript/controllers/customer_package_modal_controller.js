import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["modal", "container", "totalItems", "packageLimit", "packageId", "submitButton", "progressBar", "packagePreview", "totalItemsBottom", "packageLimitBottom"]
    static values = {
        limit: Number
    }

    connect() {
        this.currentLimit = 0
        this.selectedProducts = new Map() // Track selected products for preview

        // Add keyboard event listener for Escape key
        this.boundKeydown = this.handleKeydown.bind(this)
        document.addEventListener('keydown', this.boundKeydown)

        // Add event delegation for dynamically created buttons
        this.boundChangeQuantity = this.changeQuantity.bind(this)
        if (this.hasContainerTarget) {
            this.containerTarget.addEventListener('click', this.boundChangeQuantity)
        }

        console.log('Customer package modal controller connected')
    }

    disconnect() {
        // Clean up keyboard event listener
        document.removeEventListener('keydown', this.boundKeydown)
        // Clean up event delegation
        if (this.hasContainerTarget) {
            this.containerTarget.removeEventListener('click', this.boundChangeQuantity)
        }
    }

    handleKeydown(event) {
        if (event.key === 'Escape') {
            if (this.hasModalTarget && !this.modalTarget.classList.contains('hidden')) {
                this.close()
            }
        }
    }

    open(event) {
        const packageId = event.currentTarget.dataset.customerPackageModalPackageIdParam
        const packageLimit = parseInt(event.currentTarget.dataset.customerPackageModalPackageLimitParam)
        const productsData = event.currentTarget.dataset.customerPackageModalProductsParam

        this.currentLimit = packageLimit
        // Set global variable for the quantity functions
        window.currentPackageLimit = packageLimit

        this.openCustomerModal(packageId, packageLimit, productsData)
    }

    openCustomerModal(packageId, packageLimit, productsData) {
        // Customer page logic
        if (this.hasPackageIdTarget) {
            this.packageIdTarget.value = packageId
        }
        if (this.hasPackageLimitTarget) {
            this.packageLimitTarget.textContent = packageLimit
        }
        if (this.hasPackageLimitBottomTarget) {
            this.packageLimitBottomTarget.textContent = packageLimit
        }

        // Clear container using DOM methods instead of innerHTML
        if (this.hasContainerTarget) {
            while (this.containerTarget.firstChild) {
                this.containerTarget.removeChild(this.containerTarget.firstChild)
            }
        }
        this.selectedProducts.clear()

        // Parse products data - handle both old format (array) and new format (object with categories)
        let products
        try {
            const parsed = JSON.parse(productsData)
            if (Array.isArray(parsed)) {
                // Old format - convert to new grouped format
                products = {
                    crinkles: parsed.filter(p => p.category === 'Crinkles'),
                    extras: parsed.filter(p => p.category === 'Extras'),
                    merch: parsed.filter(p => p.category === 'Merch')
                }
            } else {
                // New format - already grouped
                products = parsed
            }
        } catch (e) {
            console.error("Error parsing products data:", e)
            products = { crinkles: [], extras: [], merch: [] }
        }

        // Create product sections
        this.createProductSection('Crinkles', products.crinkles || [], 'crinkles')
        this.createProductSection('Extras', products.extras || [], 'extras')
        this.createProductSection('Merchandise', products.merch || [], 'merch')

        if (this.hasModalTarget) {
            this.modalTarget.classList.remove('hidden')
        }
        this.updateTotal()
        this.updatePreview()
    }

    createProductSection(title, products, category) {
        if (!products || products.length === 0) return

        const sectionDiv = document.createElement('div')
        sectionDiv.className = 'mb-6'

        const sectionHeader = document.createElement('div')
        sectionHeader.className = 'mb-3'

        const titleH4 = document.createElement('h4')
        titleH4.className = 'text-lg font-semibold text-orange-950'
        titleH4.textContent = title

        const subtitleP = document.createElement('p')
        subtitleP.className = 'text-sm text-orange-600'
        subtitleP.textContent = `Select your ${title.toLowerCase()}`

        sectionHeader.appendChild(titleH4)
        sectionHeader.appendChild(subtitleP)

        const productsContainer = document.createElement('div')
        productsContainer.className = 'grid grid-cols-1 xl:grid-cols-2 gap-3'

        products.forEach(product => {
            const productDiv = this.createProductCard(product, category)
            productsContainer.appendChild(productDiv)
        })

        sectionDiv.appendChild(sectionHeader)
        sectionDiv.appendChild(productsContainer)
        if (this.hasContainerTarget) {
            this.containerTarget.appendChild(sectionDiv)
        }
    }

    createProductCard(product, category) {
        const div = document.createElement('div')
        div.className = 'flex items-center justify-between p-3 sm:p-4 border border-orange-200 rounded-lg bg-orange-50 hover:bg-orange-100 transition-colors'

        // Product image - responsive sizing
        let imageElement;
        if (product.primary_image_url) {
            imageElement = document.createElement('img')
            imageElement.src = product.primary_image_url
            imageElement.alt = product.name
            imageElement.className = 'w-12 h-12 sm:w-16 sm:h-16 xl:w-14 xl:h-14 object-cover rounded-lg flex-shrink-0'
        } else {
            imageElement = document.createElement('div')
            imageElement.className = 'w-12 h-12 sm:w-16 sm:h-16 xl:w-14 xl:h-14 bg-orange-100 rounded-lg flex items-center justify-center flex-shrink-0'
            const span = document.createElement('span')
            span.className = 'text-orange-600 font-medium text-xs sm:text-sm'
            span.textContent = product.name.charAt(0).toUpperCase()
            imageElement.appendChild(span)
        }

        // Product name and description
        const nameDiv = document.createElement('div')
        nameDiv.className = 'flex-1 min-w-0 ml-2 sm:ml-4'

        const nameH5 = document.createElement('h5')
        nameH5.className = 'font-semibold text-orange-950 text-xs sm:text-sm xl:text-base truncate'
        nameH5.textContent = product.name

        const categoryP = document.createElement('p')
        categoryP.className = 'text-orange-700 text-xs'
        categoryP.textContent = category

        nameDiv.appendChild(nameH5)
        nameDiv.appendChild(categoryP)

        // Quantity controls container
        const controlsDiv = document.createElement('div')
        controlsDiv.className = 'flex items-center space-x-2 sm:space-x-3 flex-shrink-0'

        // Minus button
        const minusButton = document.createElement('button')
        minusButton.type = 'button'
        minusButton.className = 'w-8 h-8 sm:w-7 sm:h-7 rounded-full bg-orange-600 text-white flex items-center justify-center hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-1 transition-colors disabled:opacity-50 disabled:cursor-not-allowed touch-manipulation'
        minusButton.setAttribute('data-product-id', product.id)
        minusButton.setAttribute('data-product-name', product.name)
        minusButton.setAttribute('data-product-image', product.primary_image_url || '')
        minusButton.setAttribute('data-change', '-1')
        minusButton.id = `minus-${product.id}`

        const minusSvg = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
        minusSvg.setAttribute('class', 'w-4 h-4 sm:w-3 sm:h-3')
        minusSvg.setAttribute('fill', 'none')
        minusSvg.setAttribute('stroke', 'currentColor')
        minusSvg.setAttribute('viewBox', '0 0 24 24')
        const minusPath = document.createElementNS('http://www.w3.org/2000/svg', 'path')
        minusPath.setAttribute('stroke-linecap', 'round')
        minusPath.setAttribute('stroke-linejoin', 'round')
        minusPath.setAttribute('stroke-width', '2')
        minusPath.setAttribute('d', 'M20 12H4')
        minusSvg.appendChild(minusPath)
        minusButton.appendChild(minusSvg)

        // Quantity display
        const quantitySpan = document.createElement('span')
        quantitySpan.className = 'w-8 sm:w-10 text-center font-semibold text-orange-900 text-xs sm:text-sm'
        quantitySpan.id = `quantity-${product.id}`
        quantitySpan.textContent = '0'

        // Plus button
        const plusButton = document.createElement('button')
        plusButton.type = 'button'
        plusButton.className = 'w-8 h-8 sm:w-7 sm:h-7 rounded-full bg-orange-600 text-white flex items-center justify-center hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-1 transition-colors disabled:opacity-50 disabled:cursor-not-allowed touch-manipulation'
        plusButton.setAttribute('data-product-id', product.id)
        plusButton.setAttribute('data-product-name', product.name)
        plusButton.setAttribute('data-product-image', product.primary_image_url || '')
        plusButton.setAttribute('data-change', '1')
        plusButton.id = `plus-${product.id}`

        const plusSvg = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
        plusSvg.setAttribute('class', 'w-4 h-4 sm:w-3 sm:h-3')
        plusSvg.setAttribute('fill', 'none')
        plusSvg.setAttribute('stroke', 'currentColor')
        plusSvg.setAttribute('viewBox', '0 0 24 24')
        const plusPath = document.createElementNS('http://www.w3.org/2000/svg', 'path')
        plusPath.setAttribute('stroke-linecap', 'round')
        plusPath.setAttribute('stroke-linejoin', 'round')
        plusPath.setAttribute('stroke-width', '2')
        plusPath.setAttribute('d', 'M12 4v16m8-8H4')
        plusSvg.appendChild(plusPath)
        plusButton.appendChild(plusSvg)

        // Hidden input
        const hiddenInput = document.createElement('input')
        hiddenInput.type = 'hidden'
        hiddenInput.name = `product_quantities[${product.id}]`
        hiddenInput.value = '0'
        hiddenInput.id = `hidden-${product.id}`

        // Assemble the controls
        controlsDiv.appendChild(minusButton)
        controlsDiv.appendChild(quantitySpan)
        controlsDiv.appendChild(plusButton)

        // Assemble the card
        div.appendChild(imageElement)
        div.appendChild(nameDiv)
        div.appendChild(controlsDiv)
        div.appendChild(hiddenInput)

        return div
    }

    close() {
        this.closeCustomerModal()
    }

    closeCustomerModal() {
        if (this.hasModalTarget) {
            this.modalTarget.classList.add('hidden')
        }
        this.selectedProducts.clear()
    }

    changeQuantity(event) {
        // Check if the clicked element is a quantity button
        const button = event.target.closest('button[data-change]')
        if (!button) {
            return
        }

        const productId = button.dataset.productId
        const change = parseInt(button.dataset.change)
        const quantitySpan = document.getElementById(`quantity-${productId}`)
        const hiddenInput = document.getElementById(`hidden-${productId}`)

        // Add null checks for required elements
        if (!quantitySpan || !hiddenInput) {
            return
        }

        let currentQuantity = parseInt(quantitySpan.textContent) || 0
        let newQuantity = currentQuantity + change

        // Ensure quantity doesn't go below 0
        newQuantity = Math.max(0, newQuantity)

        // Check if adding this item would exceed the limit
        const currentTotal = this.getCurrentTotal()
        if (change > 0 && currentTotal >= this.currentLimit) {
            // Don't allow adding more items
            return
        }

        quantitySpan.textContent = newQuantity
        hiddenInput.value = newQuantity

        // Update selected products for preview
        if (newQuantity > 0) {
            this.selectedProducts.set(productId, {
                id: productId,
                name: button.dataset.productName || 'Unknown Product',
                quantity: newQuantity,
                image: button.dataset.productImage || null
            })
        } else {
            this.selectedProducts.delete(productId)
        }

        this.updateTotal()
        this.updatePreview()
    }

    getCurrentTotal() {
        if (this.hasContainerTarget) {
            const inputs = this.containerTarget.querySelectorAll('input[type="hidden"]')
            return Array.from(inputs).reduce((sum, input) => sum + (parseInt(input.value) || 0), 0)
        }
        return 0
    }

    updateTotal() {
        const total = this.getCurrentTotal()

        // Add null checks for targets
        if (this.hasTotalItemsTarget) {
            this.totalItemsTarget.textContent = total
        }

        if (this.hasTotalItemsBottomTarget) {
            this.totalItemsBottomTarget.textContent = total
        }

        // Update progress bar using CSS classes instead of inline styles (CSP compliant)
        if (this.hasProgressBarTarget) {
            const percentage = Math.min((total / this.currentLimit) * 100, 100)
            // Remove existing width classes
            this.progressBarTarget.classList.remove('w-0', 'w-1/4', 'w-1/2', 'w-3/4', 'w-full')

            // Add appropriate width class based on percentage
            if (percentage === 0) {
                this.progressBarTarget.classList.add('w-0')
            } else if (percentage <= 25) {
                this.progressBarTarget.classList.add('w-1/4')
            } else if (percentage <= 50) {
                this.progressBarTarget.classList.add('w-1/2')
            } else if (percentage <= 75) {
                this.progressBarTarget.classList.add('w-3/4')
            } else {
                this.progressBarTarget.classList.add('w-full')
            }
        }

        // Disable submit button if total exceeds limit
        if (this.hasSubmitButtonTarget) {
            const isOverLimit = total > this.currentLimit
            this.submitButtonTarget.disabled = isOverLimit
            this.submitButtonTarget.classList.toggle('opacity-50', isOverLimit)
            this.submitButtonTarget.classList.toggle('cursor-not-allowed', isOverLimit)
        }

        // Update button states
        this.updateButtonStates(total)
    }

    updateButtonStates(total) {
        if (this.hasContainerTarget) {
            const plusButtons = this.containerTarget.querySelectorAll('button[data-change="1"]')
            plusButtons.forEach(button => {
                button.disabled = total >= this.currentLimit
            })
        }
    }

    updatePreview() {
        if (!this.hasPackagePreviewTarget) {
            return
        }

        const previewContainer = this.packagePreviewTarget

        // Clear preview container using DOM methods
        while (previewContainer.firstChild) {
            previewContainer.removeChild(previewContainer.firstChild)
        }

        if (this.selectedProducts.size === 0) {
            const emptyDiv = document.createElement('div')
            emptyDiv.className = 'text-sm text-orange-600 text-center py-8'
            emptyDiv.textContent = 'Select items to see your package preview'
            previewContainer.appendChild(emptyDiv)
            return
        }
        this.selectedProducts.forEach((product, productId) => {
            const itemDiv = document.createElement('div')
            itemDiv.className = 'flex items-center space-x-3 p-2 bg-white rounded border border-orange-200'

            let imageElement;
            if (product.image) {
                imageElement = document.createElement('img')
                imageElement.src = product.image
                imageElement.alt = product.name
                imageElement.className = 'w-12 h-12 object-cover rounded-lg'
            } else {
                imageElement = document.createElement('div')
                imageElement.className = 'w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center'
                const span = document.createElement('span')
                span.className = 'text-orange-600 font-medium text-xs'
                span.textContent = product.name.charAt(0).toUpperCase()
                imageElement.appendChild(span)
            }

            const contentDiv = document.createElement('div')
            contentDiv.className = 'flex-1 min-w-0'

            const nameP = document.createElement('p')
            nameP.className = 'text-sm font-medium text-orange-950 truncate'
            nameP.textContent = product.name

            const qtyP = document.createElement('p')
            qtyP.className = 'text-xs text-orange-600'
            qtyP.textContent = `Qty: ${product.quantity}`

            contentDiv.appendChild(nameP)
            contentDiv.appendChild(qtyP)

            itemDiv.appendChild(imageElement)
            itemDiv.appendChild(contentDiv)
            previewContainer.appendChild(itemDiv)
        })
    }
}
