class CartController < ApplicationController
  before_action :set_cart
  before_action :set_cart_item, only: [:update_quantity, :remove_item]

  def show
    @cart_items = @cart.cart_items.includes(:product, :crinkle_package)
    # Clean up any invalid cart items
    @cart_items.each do |item|
      item.destroy if item.product.nil? && item.crinkle_package.nil?
    end
  end

  def add_product
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i

    if @cart.add_product(product, quantity)
      redirect_to cart_path, notice: 'Product added to cart successfully.'
    else
      redirect_to products_path, alert: 'Failed to add product to cart.'
    end
  end

  def add_package
    package = CrinklePackage.find(params[:package_id])
    product_quantities = params[:product_quantities] || {}

    if @cart.add_package(package, product_quantities)
      redirect_to cart_path, notice: 'Package added to cart successfully.'
    else
      redirect_to products_path, alert: 'Failed to add package to cart.'
    end
  end

  def update_quantity
    if @cart_item
      if @cart_item.update(quantity: params[:quantity])
        redirect_to cart_path, notice: 'Cart updated successfully.'
      else
        redirect_to cart_path, alert: 'Failed to update cart.'
      end
    else
      redirect_to cart_path, alert: 'Item not found in cart.'
    end
  end

  def remove_item
    if @cart_item
      @cart_item.destroy
      redirect_to cart_path, notice: 'Item removed from cart.'
    else
      redirect_to cart_path, alert: 'Item not found in cart.'
    end
  end

  def clear
    @cart.cart_items.destroy_all
    redirect_to cart_path, notice: 'Cart cleared successfully.'
  end

  private

  def set_cart
    @cart = current_cart
  end

  def set_cart_item
    cart_item_id = params[:cart_item_id] || params[:id]
    @cart_item = @cart.cart_items.find_by(id: cart_item_id)
    if @cart_item && @cart_item.product.nil? && @cart_item.crinkle_package.nil?
      @cart_item.destroy
      @cart_item = nil
    end
  end
end