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
    unless @content_block
      redirect_to admin_content_blocks_path, alert: 'Content block not found.'
      return
    end

    # Debug logging
    Rails.logger.info "=== CONTENT BLOCK UPDATE DEBUG ==="
    Rails.logger.info "Current content: #{@content_block.content.inspect}"
    Rails.logger.info "New content: #{content_block_params[:content].inspect}"
    Rails.logger.info "Content changed: #{@content_block.content != content_block_params[:content]}"
    Rails.logger.info "Params: #{content_block_params.inspect}"

    # Validate JSON content if content_type is json
    if content_block_params[:content_type] == 'json' && content_block_params[:content].present?
      begin
        JSON.parse(content_block_params[:content])
      rescue JSON::ParserError => e
        @content_block.assign_attributes(content_block_params)
        @content_block.errors.add(:content, "Invalid JSON format: #{e.message}")
        flash.now[:alert] = 'There were errors updating the content block. Please check the form below.'
        render :edit, status: :unprocessable_entity
        return
      end
    end
    
    # Assign attributes first to check for changes
    @content_block.assign_attributes(content_block_params)
    Rails.logger.info "After assign_attributes - changed?: #{@content_block.changed?}"
    Rails.logger.info "Changes: #{@content_block.changes.inspect}"
    
    if @content_block.save
      Rails.logger.info "Content block saved successfully"
      redirect_to admin_content_blocks_path, notice: 'Content block was successfully updated.'
    else
      Rails.logger.error "Content block save failed: #{@content_block.errors.full_messages}"
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
    permitted_params = params.require(:content_block).permit(:key, :title, :content, :content_type, :preview_url, :image, images: [], page_locations: [], metadata: {})
    
    # Filter out empty strings from page_locations array
    if permitted_params[:page_locations].present?
      permitted_params[:page_locations] = permitted_params[:page_locations].reject(&:blank?)
    else
      permitted_params[:page_locations] = []
    end
    
    # Strip whitespace from content if present
    if permitted_params[:content].present?
      permitted_params[:content] = permitted_params[:content].strip
    end
    
    permitted_params
  end
end 