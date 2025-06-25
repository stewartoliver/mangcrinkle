import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["container", "totalItems", "packageLimit", "packageId", "submitButton"]
    static values = {
        limit: Number
    }

    connect() {
        console.log("Package modal controller connected")
        this.currentLimit = 0
    }

    open(event) {
        console.log("Opening package modal", event.currentTarget.dataset)
        const packageId = event.currentTarget.dataset.packageModalPackageIdParam
        const packageLimit = parseInt(event.currentTarget.dataset.packageModalPackageLimitParam)
        const products = JSON.parse(event.currentTarget.dataset.packageModalProductsParam)

        console.log("Package data:", { packageId, packageLimit, products })

        this.currentLimit = packageLimit
        // Set global variable for the quantity functions
        window.currentPackageLimit = packageLimit
        this.packageIdTarget.value = packageId
        this.packageLimitTarget.textContent = packageLimit

        this.containerTarget.innerHTML = ''

        products.forEach(product => {
            const div = document.createElement('div')
            div.className = 'flex items-center justify-between p-3 border border-orange-200 rounded-lg bg-orange-50'

            // Product image
            let imageHtml = '';
            if (product.image_url) {
                imageHtml = `<img src="${product.image_url}" alt="${product.name}" class="w-12 h-12 object-cover rounded-lg flex-shrink-0">`;
            } else {
                imageHtml = `<div class="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center flex-shrink-0">
                     <span class="text-orange-600 font-medium text-xs">${product.name.charAt(0).toUpperCase()}</span>
                   </div>`;
            }

            // Product name
            const nameHtml = `<div class="flex-1 min-w-0">
                       <h4 class="font-semibold text-orange-950 text-sm truncate">${product.name}</h4>
                     </div>`;

            // Quantity controls
            const quantityControls = `
      <div class="flex items-center space-x-2 flex-shrink-0">
        <button type="button" 
                class="w-8 h-8 rounded-full bg-orange-600 text-white flex items-center justify-center hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-1 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                onclick="changeQuantity(${product.id}, -1)"
                id="minus-${product.id}">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4"></path>
          </svg>
        </button>
        <span class="w-10 text-center font-semibold text-orange-900 text-sm" id="quantity-${product.id}">0</span>
        <button type="button" 
                class="w-8 h-8 rounded-full bg-orange-600 text-white flex items-center justify-center hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-orange-500 focus:ring-offset-1 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                onclick="changeQuantity(${product.id}, 1)"
                id="plus-${product.id}">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
          </svg>
        </button>
      </div>`;

            div.innerHTML = `
      ${imageHtml}
      ${nameHtml}
      ${quantityControls}
      <input type="hidden" name="product_quantities[${product.id}]" value="0" id="hidden-${product.id}">
    `;

            this.containerTarget.appendChild(div)
            console.log('Added product input for:', product.name, 'with ID:', product.id)
        })

        this.element.classList.remove('hidden')
        this.updateTotal()
    }

    close() {
        console.log("Closing package modal")
        this.element.classList.add('hidden')
    }

    updateTotal() {
        const inputs = this.containerTarget.querySelectorAll('input[type="hidden"]')
        const total = Array.from(inputs).reduce((sum, input) => sum + (parseInt(input.value) || 0), 0)
        this.totalItemsTarget.textContent = total

        console.log('Updated total:', total, 'Limit:', this.currentLimit)

        // Disable submit button if total exceeds limit
        this.submitButtonTarget.disabled = total > this.currentLimit
        this.submitButtonTarget.classList.toggle('opacity-50', total > this.currentLimit)
        this.submitButtonTarget.classList.toggle('cursor-not-allowed', total > this.currentLimit)
    }
} 