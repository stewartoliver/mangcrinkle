import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["modal", "container", "totalItems", "packageLimit", "packageId", "submitButton", "progressBar", "packagePreview", "totalItemsBottom", "packageLimitBottom"]
    static values = {
        limit: Number
    }

    connect() {
        this.currentLimit = 0
        this.selectedProducts = new Map()

        // Add keyboard event listener for Escape key
        this.boundKeydown = this.handleKeydown.bind(this)
        document.addEventListener('keydown', this.boundKeydown)

        // Add event delegation for dynamically created buttons
        this.boundChangeQuantity = this.changeQuantity.bind(this)
    }

    disconnect() {
        // Clean up keyboard event listener
        document.removeEventListener('keydown', this.boundKeydown)
        // Clean up event delegation from modal container
        const adminContainer = document.getElementById('productSelectionContainer')
        if (adminContainer && this.boundChangeQuantity) {
            adminContainer.removeEventListener('click', this.boundChangeQuantity)
        }
    }

    handleKeydown(event) {
        if (event.key === 'Escape') {
            const adminModal = document.getElementById('adminPackageModal')
            if (adminModal && !adminModal.classList.contains('hidden')) {
                this.close()
            }
        }
    }

    open(event) {
        const packageId = event.currentTarget.dataset.adminPackageModalPackageIdParam
        const packageLimit = parseInt(event.currentTarget.dataset.adminPackageModalPackageLimitParam)
        const productsData = event.currentTarget.dataset.adminPackageModalProductsParam

        this.currentLimit = packageLimit
        window.currentPackageLimit = packageLimit

        this.openAdminModal(packageId, packageLimit, productsData)
    }

    openAdminModal(packageId, packageLimit, productsData) {
        const adminModal = document.getElementById('adminPackageModal')
        const adminPackageId = document.getElementById('packageId')
        const adminPackageLimit = document.getElementById('packageLimit')
        const adminContainer = document.getElementById('productSelectionContainer')

        if (!adminModal || !adminPackageId || !adminPackageLimit || !adminContainer) {
            console.error("Admin modal elements not found")
            return
        }

        // Set package data
        adminPackageId.value = packageId
        adminPackageLimit.textContent = packageLimit

        // Clear container
        while (adminContainer.firstChild) {
            adminContainer.removeChild(adminContainer.firstChild)
        }

        // Parse products data
        let products
        try {
            const parsed = JSON.parse(productsData)
            if (Array.isArray(parsed)) {
                products = parsed
            } else {
                // Convert grouped format to flat array for admin modal
                products = [
                    ...(parsed.crinkles || []),
                    ...(parsed.extras || []),
                    ...(parsed.merch || [])
                ]
            }
        } catch (e) {
            console.error("Error parsing products data:", e)
            products = []
        }

        // Create product cards for admin modal
        products.forEach(product => {
            const productCard = this.createAdminProductCard(product)
            adminContainer.appendChild(productCard)
        })

        // Show modal
        adminModal.classList.remove('hidden')
        document.body.classList.add('modal-body-overflow-hidden', 'modal-body-position-fixed', 'modal-body-width-full');

        // Add event listener to the container for quantity changes
        if (this.boundChangeQuantity) {
            adminContainer.addEventListener('click', this.boundChangeQuantity)
        }

        // Update total items
        this.updateAdminTotal()
    }

    createAdminProductCard(product) {
        const div = document.createElement('div')
        div.className = 'flex items-center justify-between p-3 border border-orange-200 rounded-lg bg-orange-50'

        // Product image
        let imageElement;
        if (product.primary_image_url) {
            imageElement = document.createElement('img')
            imageElement.src = product.primary_image_url
            imageElement.alt = product.name
            imageElement.className = 'w-12 h-12 object-cover rounded-lg flex-shrink-0'
        } else {
            imageElement = document.createElement('div')
            imageElement.className = 'w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center flex-shrink-0'
            const span = document.createElement('span')
            span.className = 'text-orange-600 font-medium text-xs'
            span.textContent = product.name.charAt(0).toUpperCase()
            imageElement.appendChild(span)
        }

        // Product name
        const nameDiv = document.createElement('div')
        nameDiv.className = 'flex-1 min-w-0 ml-3'
        const nameH4 = document.createElement('h4')
        nameH4.className = 'font-semibold text-orange-950 text-sm truncate'
        nameH4.textContent = product.name
        nameDiv.appendChild(nameH4)

        // Quantity controls
        const controlsDiv = document.createElement('div')
        controlsDiv.className = 'flex items-center space-x-2 flex-shrink-0'

        // Minus button
        const minusButton = document.createElement('button')
        minusButton.type = 'button'
        minusButton.className = 'w-8 h-8 rounded-full bg-orange-600 text-white flex items-center justify-center hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-1 transition-colors disabled:opacity-50 disabled:cursor-not-allowed'
        minusButton.setAttribute('data-product-id', product.id)
        minusButton.setAttribute('data-change', '-1')
        minusButton.id = `minus-${product.id}`

        const minusSvg = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
        minusSvg.setAttribute('class', 'w-4 h-4')
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
        quantitySpan.className = 'w-10 text-center font-semibold text-orange-900 text-sm'
        quantitySpan.id = `quantity-${product.id}`
        quantitySpan.textContent = '0'

        // Plus button
        const plusButton = document.createElement('button')
        plusButton.type = 'button'
        plusButton.className = 'w-8 h-8 rounded-full bg-orange-600 text-white flex items-center justify-center hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-1 transition-colors disabled:opacity-50 disabled:cursor-not-allowed'
        plusButton.setAttribute('data-product-id', product.id)
        plusButton.setAttribute('data-change', '1')
        plusButton.id = `plus-${product.id}`

        const plusSvg = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
        plusSvg.setAttribute('class', 'w-4 h-4')
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
        this.closeAdminModal()
    }

    closeAdminModal() {
        const adminModal = document.getElementById('adminPackageModal')
        if (adminModal) {
            adminModal.classList.add('hidden')
            document.body.classList.remove('modal-body-overflow-hidden', 'modal-body-position-fixed', 'modal-body-width-full');
        }

        // Remove event listener from container
        const adminContainer = document.getElementById('productSelectionContainer')
        if (adminContainer && this.boundChangeQuantity) {
            adminContainer.removeEventListener('click', this.boundChangeQuantity)
        }

        // Clear editing state
        const editingLineItemId = document.getElementById('editingLineItemId')
        if (editingLineItemId) {
            editingLineItemId.value = ''
        }
    }

    changeQuantity(event) {
        const button = event.target.closest('button[data-change]')
        if (!button) return

        const productId = button.dataset.productId
        const change = parseInt(button.dataset.change)
        const quantitySpan = document.getElementById(`quantity-${productId}`)
        const hiddenInput = document.getElementById(`hidden-${productId}`)

        if (!quantitySpan || !hiddenInput) return

        let currentQuantity = parseInt(quantitySpan.textContent) || 0
        let newQuantity = currentQuantity + change
        newQuantity = Math.max(0, newQuantity)

        const currentTotal = this.getCurrentTotal()
        if (change > 0 && currentTotal >= this.currentLimit) {
            return
        }

        quantitySpan.textContent = newQuantity
        hiddenInput.value = newQuantity

        this.updateAdminTotal()
    }

    getCurrentTotal() {
        const adminContainer = document.getElementById('productSelectionContainer')
        if (!adminContainer) return 0
        const inputs = adminContainer.querySelectorAll('input[type="hidden"]')
        return Array.from(inputs).reduce((sum, input) => sum + (parseInt(input.value) || 0), 0)
    }

    updateAdminTotal() {
        const total = this.getCurrentTotal()

        const totalItemsElement = document.getElementById('totalItems')
        if (totalItemsElement) {
            totalItemsElement.textContent = total
        }

        // Update button states
        this.updateAdminButtonStates(total)
    }

    updateAdminButtonStates(total) {
        const adminContainer = document.getElementById('productSelectionContainer')
        if (!adminContainer) return

        const plusButtons = adminContainer.querySelectorAll('button[data-change="1"]')
        plusButtons.forEach(button => {
            button.disabled = total >= this.currentLimit
        })
    }

    // Handle submit button click
    submitPackage() {
        // Call the existing admin order handlers function
        if (typeof window.addPackageToOrderImpl === 'function') {
            window.addPackageToOrderImpl()
            this.closeAdminModal()
        } else {
            console.error("window.addPackageToOrderImpl is not defined.")
        }
    }
}
