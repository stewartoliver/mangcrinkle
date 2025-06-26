class Admin::CompaniesController < Admin::BaseController
  before_action :set_company, only: [:show, :edit, :update, :destroy]

  def index
    @companies = Company.ordered
    @companies = @companies.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
  end

  def show
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    
    if @company.save
      redirect_to admin_company_path(@company), notice: 'Company was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @company.update(company_params)
      redirect_to admin_company_path(@company), notice: 'Company was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @company.destroy
    redirect_to admin_companies_path, notice: 'Company was successfully deleted.'
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :website, :address, :phone, :email, :description, :active, :logo, business_hours: {})
  end
end 