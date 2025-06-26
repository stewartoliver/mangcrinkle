class Admin::CrinklePackagesController < Admin::BaseController
  before_action :set_crinkle_package, only: [:show, :edit, :update, :destroy]

  def index
    @crinkle_packages = CrinklePackage.all.ordered_by_quantity
  end

  def show
  end

  def new
    @crinkle_package = CrinklePackage.new
  end

  def create
    @crinkle_package = CrinklePackage.new(crinkle_package_params)

    if @crinkle_package.save
      redirect_to admin_crinkle_package_path(@crinkle_package), notice: 'Package was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @crinkle_package.update(crinkle_package_params)
      redirect_to admin_crinkle_package_path(@crinkle_package), notice: 'Package was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @crinkle_package.destroy
    redirect_to admin_crinkle_packages_path, notice: 'Package was successfully deleted.'
  end

  private

  def set_crinkle_package
    @crinkle_package = CrinklePackage.find(params[:id])
  end

  def crinkle_package_params
    params.require(:crinkle_package).permit(:name, :price, :quantity, :image, :active, :description)
  end
end 