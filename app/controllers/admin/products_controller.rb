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
  end

  def create
    Rails.logger.debug "Creating product with images: #{params[:product][:images]&.length || 0}" if Rails.env.development?
    
    # Extract images from params to handle separately
    new_images = params[:product][:images]
    product_params_without_images = product_params.except(:images)
    
    @product = Product.new(product_params_without_images)

    if @product.save
      # Handle images if provided
      if new_images.present? && new_images.any? { |img| img.present? }
        valid_images = new_images.select(&:present?)
        
        Rails.logger.debug "Valid new images: #{valid_images.length}" if Rails.env.development?
        
        # Check if images would exceed the limit
        if valid_images.length > 3
          @product.errors.add(:images, "Cannot upload #{valid_images.length} images. Maximum 3 images allowed")
          @product.destroy # Clean up the created product
          render :new, status: :unprocessable_entity
          return
        end
        
        # Attach images
        @product.images.attach(valid_images)
        Rails.logger.debug "Images attached. Total: #{@product.images.count}" if Rails.env.development?
      end
      
      Rails.logger.debug "Product saved successfully with #{@product.images.count} images" if Rails.env.development?
      redirect_to admin_product_path(@product), notice: 'Product was successfully created.'
    else
      Rails.logger.debug "Product save failed: #{@product.errors.full_messages}" if Rails.env.development?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # Handle primary image setting first if provided
    primary_image_param = params[:primary_image_id]
    
    Rails.logger.debug "Updating product with images: #{params[:product][:images]&.length || 0}" if Rails.env.development?
    Rails.logger.debug "Primary image param: #{primary_image_param}" if Rails.env.development?
    Rails.logger.debug "Current images count: #{@product.images.count}" if Rails.env.development?
    
    # Extract images from params to handle separately
    new_images = params[:product][:images]
    product_params_without_images = product_params.except(:images)
    
    # Update product attributes first (without images)
    if @product.update(product_params_without_images)
      # Handle new images if provided
      if new_images.present? && new_images.any? { |img| img.present? }
        valid_images = new_images.select(&:present?)
        current_count = @product.images.count
        
        Rails.logger.debug "Valid new images: #{valid_images.length}" if Rails.env.development?
        Rails.logger.debug "Current count: #{current_count}" if Rails.env.development?
        
        # Check if adding new images would exceed the limit
        if current_count + valid_images.length > 3
          @product.errors.add(:images, "Cannot add #{valid_images.length} more images. Maximum 3 images allowed (currently have #{current_count})")
          render :edit, status: :unprocessable_entity
          return
        end
        
        # Attach new images (this appends to existing images)
        @product.images.attach(valid_images)
        Rails.logger.debug "Images attached. New total: #{@product.images.count}" if Rails.env.development?
      end
      
      Rails.logger.debug "Product updated successfully with #{@product.images.count} images" if Rails.env.development?
      
      # Set primary image after successful update to avoid conflicts
      if primary_image_param.present?
        @product.update_column(:primary_image_id, primary_image_param)
        Rails.logger.debug "Primary image set to: #{primary_image_param}" if Rails.env.development?
      end
      
      redirect_to admin_product_path(@product), notice: 'Product was successfully updated.'
    else
      Rails.logger.debug "Product update failed: #{@product.errors.full_messages}" if Rails.env.development?
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
    
    # Find and remove the image
    image_to_remove = @product.all_images.find { |img| img.id.to_s == image_id }
    
    if image_to_remove
      # Reset primary image if it was the removed image
      if @product.primary_image_id == image_id
        @product.update_column(:primary_image_id, nil)
      end
      
      # Remove the image
      image_to_remove.purge
      
      render json: { success: true, message: 'Image removed successfully' }
    else
      render json: { error: 'Image not found' }, status: :not_found
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :price, :active, :description, :short_description, :category, images: [])
  end
end 