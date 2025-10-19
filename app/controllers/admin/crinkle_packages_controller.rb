class Admin::CrinklePackagesController < Admin::BaseController
  before_action :set_crinkle_package, only: [:show, :edit, :update, :destroy, :manage_products]

  def index
    @crinkle_packages = CrinklePackage.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @crinkle_package = CrinklePackage.new
    @products = Product.active.order(:category, :name)
    @package_products = []
  end

  def create
    @crinkle_package = CrinklePackage.new(crinkle_package_params)
    @products = Product.active.order(:category, :name)
    @package_products = []

    if @crinkle_package.save
      # Handle package products if provided
      if package_products_params[:package_products].present?
        create_package_products
      end
      redirect_to admin_crinkle_package_path(@crinkle_package), notice: 'Package was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @products = Product.active.order(:category, :name)
    @package_products = @crinkle_package.package_products.includes(:product)
  end

  def update
    @products = Product.active.order(:category, :name)
    @package_products = @crinkle_package.package_products.includes(:product)
    
    if @crinkle_package.update(crinkle_package_params)
      # Handle package products if provided
      if package_products_params[:package_products].present?
        update_package_products
      end
      redirect_to admin_crinkle_package_path(@crinkle_package), notice: 'Package was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @crinkle_package.destroy
    redirect_to admin_crinkle_packages_path, notice: 'Package was successfully deleted.'
  end

  def manage_products
    @products = Product.active.order(:category, :name)
    @package_products = @crinkle_package.package_products.includes(:product)
  end

  def update_products
    @crinkle_package = CrinklePackage.find(params[:id])
    
    # Clear existing package products
    @crinkle_package.package_products.destroy_all
    
    # Add new package products
    if package_products_params[:package_products].present?
      package_products_params[:package_products].each do |product_id, attributes|
        # Only create package products if they are marked as active
        next unless attributes["active"] == '1'
        
        @crinkle_package.package_products.create!(
          product_id: product_id,
          quantity: attributes["quantity"].to_i,
          required: attributes["required"] == '1',
          active: attributes["active"] == '1'
        )
      end
    end
    
    redirect_to manage_products_admin_crinkle_package_path(@crinkle_package), notice: 'Package products were successfully updated.'
  end

  private

  def set_crinkle_package
    @crinkle_package = CrinklePackage.find(params[:id])
  end

  def crinkle_package_params
    params.require(:crinkle_package).permit(:name, :description, :price, :quantity, :active, :holiday_package, :holiday_start_date, :holiday_end_date)
  end

  def package_products_params
    params.permit(package_products: {})
  end

  def create_package_products
    package_products_params[:package_products].each do |product_id, attributes|
      # Only create package products if they are marked as active
      next unless attributes["active"] == '1'
      
      @crinkle_package.package_products.create!(
        product_id: product_id,
        quantity: attributes["quantity"].to_i,
        required: attributes["required"] == '1',
        active: attributes["active"] == '1'
      )
    end
  end

  def update_package_products
    # Clear existing package products
    @crinkle_package.package_products.destroy_all
    
    # Add new package products
    package_products_params[:package_products].each do |product_id, attributes|
      # Only create package products if they are marked as active
      next unless attributes["active"] == '1'
      
      @crinkle_package.package_products.create!(
        product_id: product_id,
        quantity: attributes["quantity"].to_i,
        required: attributes["required"] == '1',
        active: attributes["active"] == '1'
      )
    end
  end
end 