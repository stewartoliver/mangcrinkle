class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = Product.all.order(created_at: :desc)
    @products = @products.by_category(params[:category]) if params[:category].present?
    @categories = Product.available_categories
  end

  def show
  end

  def new
    @product = Product.new
    @product.active = true  # Set default to active for new products
  end

  def create
    Rails.logger.debug "=== CREATE PRODUCT START ===" if Rails.env.development?
    Rails.logger.debug "Request method: #{request.method}" if Rails.env.development?
    Rails.logger.debug "Request path: #{request.path}" if Rails.env.development?
    Rails.logger.debug "All params: #{params.inspect}" if Rails.env.development?
    Rails.logger.debug "Product params: #{product_params.inspect}" if Rails.env.development?
    Rails.logger.debug "Primary image ID param: #{params[:primary_image_id]}" if Rails.env.development?
    Rails.logger.debug "Images param: #{params[:product][:images]&.length || 0}" if Rails.env.development?
    
    @product = Product.new(product_params)
    
    Rails.logger.debug "Product object before save: #{@product.attributes}" if Rails.env.development?
    Rails.logger.debug "Product valid? #{@product.valid?}" if Rails.env.development?
    Rails.logger.debug "Product errors: #{@product.errors.full_messages}" if Rails.env.development? && !@product.valid?
    
    if @product.save
      Rails.logger.debug "Product saved successfully" if Rails.env.development?
      Rails.logger.debug "Product ID: #{@product.id}" if Rails.env.development?
      
      # Handle primary image setting
      if params[:primary_image_id].present?
        @product.update(primary_image_id: params[:primary_image_id])
        Rails.logger.debug "Set primary image to: #{params[:primary_image_id]}" if Rails.env.development?
      elsif @product.images.attached? && @product.images.any?
        # Ensure primary image is set if images were uploaded
        @product.ensure_primary_image
        Rails.logger.debug "Ensured primary image: #{@product.primary_image_id}" if Rails.env.development?
      end
      
      Rails.logger.debug "=== CREATE PRODUCT SUCCESS ===" if Rails.env.development?
      redirect_to admin_product_path(@product), notice: 'Product was successfully created.'
    else
      Rails.logger.debug "=== CREATE PRODUCT FAILED ===" if Rails.env.development?
      Rails.logger.debug "Errors: #{@product.errors.full_messages}" if Rails.env.development?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    Rails.logger.debug "=== UPDATE PRODUCT START ===" if Rails.env.development?
    Rails.logger.debug "Images before update: #{@product.images.count}" if Rails.env.development?
    Rails.logger.debug "Primary image ID before: #{@product.primary_image_id}" if Rails.env.development?
    Rails.logger.debug "New images param: #{params[:product][:images]&.length || 0}" if Rails.env.development?
    Rails.logger.debug "Primary image param: #{params[:primary_image_id]}" if Rails.env.development?
    
    # Handle image uploads separately to avoid replacing existing images
    new_images = params[:product][:images] if params[:product]
    
    # Filter out empty/blank images
    valid_new_images = new_images&.reject { |img| img.blank? || (img.respond_to?(:tempfile) && img.tempfile.nil?) }
    
    Rails.logger.debug "Valid new images count: #{valid_new_images&.length || 0}" if Rails.env.development?
    
    # Update product with other attributes (excluding images)
    if @product.update(product_params_without_images)
      Rails.logger.debug "Product updated successfully" if Rails.env.development?
      
      # Only attach new images if they exist and are valid
      if valid_new_images&.any?
        Rails.logger.debug "Attaching #{valid_new_images.count} new images" if Rails.env.development?
        @product.images.attach(valid_new_images)
        Rails.logger.debug "Images after attaching new ones: #{@product.images.count}" if Rails.env.development?
      else
        Rails.logger.debug "No valid new images to attach" if Rails.env.development?
      end
      
      # Handle primary image setting
      if params[:primary_image_id].present?
        @product.update(primary_image_id: params[:primary_image_id])
        Rails.logger.debug "Set primary image to: #{params[:primary_image_id]}" if Rails.env.development?
      elsif @product.primary_image_id.blank? && @product.images.attached? && @product.images.any?
        # Only ensure primary image if none is set and we have images
        @product.ensure_primary_image
        Rails.logger.debug "Ensured primary image: #{@product.primary_image_id}" if Rails.env.development?
      end
      
      Rails.logger.debug "=== UPDATE PRODUCT SUCCESS ===" if Rails.env.development?
      redirect_to admin_product_path(@product), notice: 'Product was successfully updated.'
    else
      Rails.logger.debug "=== UPDATE PRODUCT FAILED ===" if Rails.env.development?
      Rails.logger.debug "Errors: #{@product.errors.full_messages}" if Rails.env.development?
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to admin_products_path, notice: 'Product was successfully deleted.'
  end

  def remove_image
    @product = Product.find(params[:id])
    image_id = params[:image_id]
    
    Rails.logger.debug "Removing image with ID: #{image_id}" if Rails.env.development?
    Rails.logger.debug "Current primary image ID: #{@product.primary_image_id}" if Rails.env.development?
    
    # Find and remove the image
    image_to_remove = @product.all_images.find { |img| img.id.to_s == image_id.to_s }
    
    if image_to_remove
      # Reset primary image if it was the removed image
      if @product.primary_image_id.to_s == image_id.to_s
        @product.update_column(:primary_image_id, nil)
        Rails.logger.debug "Reset primary image ID to nil" if Rails.env.development?
      end
      
      # Remove the image
      image_to_remove.purge
      Rails.logger.debug "Image purged successfully" if Rails.env.development?
      
      render json: { success: true, message: 'Image removed successfully' }
    else
      Rails.logger.error "Image not found with ID: #{image_id}" if Rails.env.development?
      render json: { error: 'Image not found' }, status: :not_found
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :price, :active, :description, :short_description, :category, :ingredients, :allergen_info, :storage_instructions, images: [])
  end

  def product_params_without_images
    params.require(:product).permit(:name, :price, :active, :description, :short_description, :category, :ingredients, :allergen_info, :storage_instructions)
  end
end 