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
  end

  def create
    @content_block = ContentBlock.new(content_block_params)
    
    if @content_block.save
      redirect_to admin_content_blocks_path, notice: 'Content block was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @content_block.update(content_block_params)
      redirect_to admin_content_blocks_path, notice: 'Content block was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @content_block.destroy
    redirect_to admin_content_blocks_path, notice: 'Content block was successfully deleted.'
  end

  private

  def set_content_block
    @content_block = ContentBlock.find(params[:id])
  end

  def content_block_params
    permitted_params = params.require(:content_block).permit(:key, :title, :content, :content_type, :preview_url, :image, images: [], page_locations: [], metadata: {})
    
    # Filter out empty strings from page_locations array
    if permitted_params[:page_locations].present?
      permitted_params[:page_locations] = permitted_params[:page_locations].reject(&:blank?)
    else
      permitted_params[:page_locations] = []
    end
    
    permitted_params
  end
end 