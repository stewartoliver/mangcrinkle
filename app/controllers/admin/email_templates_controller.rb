class Admin::EmailTemplatesController < Admin::BaseController
  before_action :set_email_template, only: [:show, :edit, :update, :destroy, :preview]

  def index
    @email_templates = EmailTemplate.order(:template_type, :name)
    @template_types = EmailTemplate.template_types
  end

  def show
  end

  def new
    @email_template = EmailTemplate.new
  end

  def create
    @email_template = EmailTemplate.new(email_template_params)
    
    if @email_template.save
      redirect_to admin_email_template_path(@email_template), notice: 'Email template created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @email_template.update(email_template_params)
      redirect_to admin_email_template_path(@email_template), notice: 'Email template updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @email_template.destroy
    redirect_to admin_email_templates_path, notice: 'Email template deleted successfully.'
  end

  def preview
    variables = parse_preview_variables(params[:variables])
    
    if request.post?
      # Send preview email
      AdminMailer.template_preview(current_admin_user, @email_template, variables).deliver_later
      redirect_to admin_email_template_path(@email_template), notice: 'Preview email sent!'
    else
      # Show preview form
      @rendered = @email_template.render_with_variables(variables)
      @sample_variables = generate_sample_variables_for_template(@email_template)
    end
  end

  def seed_defaults
    EmailTemplate.default_templates.each do |template_type, template_data|
      next if EmailTemplate.find_by(template_type: template_type)
      
      EmailTemplate.create!(
        template_type: template_type,
        name: template_data[:name],
        subject: template_data[:subject],
        body: template_data[:body],
        variables: template_data[:variables],
        active: true
      )
    end
    
    redirect_to admin_email_templates_path, notice: 'Default templates created successfully.'
  end

  private

  def set_email_template
    @email_template = EmailTemplate.find(params[:id])
  end

  def email_template_params
    params.require(:email_template).permit(:name, :subject, :body, :template_type, :variables, :active)
  end

  def parse_preview_variables(variables_param)
    return {} if variables_param.blank?
    
    # Handle hash parameters (from preview form)
    if variables_param.is_a?(ActionController::Parameters)
      return variables_param.permit!.to_h.stringify_keys
    elsif variables_param.is_a?(Hash)
      return variables_param.stringify_keys
    end
    
    # Handle comma-separated string format (legacy)
    if variables_param.is_a?(String)
      variables = {}
      variables_param.split(',').each do |var|
        key, value = var.split('=', 2)
        variables[key.strip] = value.strip if key && value
      end
      return variables
    end
    
    {}
  end

  def generate_sample_variables_for_template(template)
    case template.template_type
    when 'order_confirmation'
      {
        'customer_name' => 'John Doe',
        'order_number' => '12345',
        'order_total' => '$25.99',
        'items' => '12 Mixed Crinkles'
      }
    when 'shipping_notification'
      {
        'customer_name' => 'Jane Smith',
        'order_number' => '67890',
        'tracking_number' => 'TR123456789',
        'estimated_delivery' => '2024-01-15'
      }
    when 'review_request'
      {
        'customer_name' => 'Bob Johnson',
        'order_number' => '54321',
        'review_link' => 'https://example.com/review'
      }
    else
      {}
    end
  end

  def current_admin_user
    current_user
  end
end 