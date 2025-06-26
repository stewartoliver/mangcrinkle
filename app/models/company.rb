class Company < ApplicationRecord
  has_one_attached :logo
  
  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true
  
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }
  
  # Helper method to get the main company (assuming one main company)
  def self.main
    active.first || new(name: "Main Company")
  end
  
  # Helper method to format business hours
  def formatted_business_hours
    return "Not specified" if business_hours.blank?
    
    if business_hours.is_a?(Hash)
      business_hours.map do |day, hours|
        "#{day.titleize}: #{hours}"
      end.join(", ")
    else
      business_hours.to_s
    end
  end
  
  # Helper method to check if logo is attached
  def has_logo?
    logo.attached?
  end
  
  # Helper method to get formatted address
  def formatted_address
    address&.gsub("\n", ", ")
  end
  
  # Helper method to get display name
  def display_name
    name.presence || "Unnamed Company"
  end
end 