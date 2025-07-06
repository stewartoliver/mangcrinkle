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
      days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
      formatted_hours = days.map do |day|
        day_data = business_hours[day]
        day_name = day.titleize
        
        if day_data.is_a?(Hash)
          if day_data['closed'] == '1'
            "#{day_name}: Closed"
          else
            open_time = day_data['open'].presence || '9:00 AM'
            close_time = day_data['close'].presence || '5:00 PM'
            "#{day_name}: #{open_time} - #{close_time}"
          end
        elsif day_data.is_a?(String)
          if day_data.downcase == 'closed'
            "#{day_name}: Closed"
          else
            "#{day_name}: #{day_data}"
          end
        else
          "#{day_name}: Closed"
        end
      end
      
      formatted_hours.join("\n")
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