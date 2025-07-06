class Admin::ContentBlocksController < Admin::BaseController
  before_action :set_content_block, only: [:show, :edit, :update, :destroy]

  def index
    @content_blocks = ContentBlock.includes(image_attachment: :blob)
                                  .ordered
                                  .page(params[:page])
    
    @content_blocks = @content_blocks.by_type(params[:content_type]) if params[:content_type].present?
    @content_blocks = @content_blocks.where('title ILIKE ? OR key ILIKE ?', "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
    @content_blocks = @content_blocks.by_page(params[:page_location]) if params[:page_location].present?
  end

  def show
  end

  def new
    @content_block = ContentBlock.new
    
    # Pre-fill attributes from params if provided
    if params[:content_block].present?
      @content_block.assign_attributes(content_block_params.except(:image, :images))
    end
  end

  def create
    @content_block = ContentBlock.new(content_block_params)
    
    if @content_block.save
      redirect_to admin_content_blocks_path, notice: 'Content block was successfully created.'
    else
      flash.now[:alert] = 'There were errors creating the content block. Please check the form below.'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # Ensure we have the content block for editing
    unless @content_block
      redirect_to admin_content_blocks_path, alert: 'Content block not found.'
      return
    end
  end

  def update
    # Ensure we have the content block for updating
    unless @content_block
      redirect_to admin_content_blocks_path, alert: 'Content block not found.'
      return
    end
    
    Rails.logger.debug "Updating content block #{@content_block.id} with params: #{content_block_params.inspect}"
    
    # Handle image removal if requested
    if params[:remove_image] == '1'
      @content_block.image.purge if @content_block.image.attached?
    end
    
    # Handle images removal if requested
    if params[:remove_images] == '1'
      @content_block.images.purge if @content_block.images.attached?
    end

    if @content_block.update(content_block_params)
      Rails.logger.debug "Content block updated successfully"
      redirect_to admin_content_blocks_path, notice: 'Content block was successfully updated.'
    else
      Rails.logger.debug "Content block update failed: #{@content_block.errors.full_messages}"
      flash.now[:alert] = 'There were errors updating the content block. Please check the form below.'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless @content_block
      redirect_to admin_content_blocks_path, alert: 'Content block not found.'
      return
    end
    
    @content_block.destroy
    redirect_to admin_content_blocks_path, notice: 'Content block was successfully deleted.'
  end

  private

  def set_content_block
    @content_block = ContentBlock.find_by(id: params[:id])
  end

  def content_block_params
    params.require(:content_block).permit(:title, :key, :content, :content_type, :image, images: [], page_locations: [])
  end
end 