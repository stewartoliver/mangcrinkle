module ApplicationHelper
  # Company helper methods
  def main_company
    @main_company ||= Company.main
  end

  def company_email
    main_company.email.presence || 'mangcrinkle@gmail.com'
  end

  def company_phone
    main_company.phone.presence || '(555) 123-4567'
  end

  def company_address
    main_company.address.presence || "123 Cookie Street\nSweet City, SC 12345"
  end

  def company_business_hours
    main_company.formatted_business_hours
  end

  def company_website
    main_company.website.presence || 'https://mangcrinkle.com'
  end

  # Additional helper methods for email templates
  def company_name
    main_company.name.presence || 'Mang Crinkle Cookies'
  end

  def company_display_name
    main_company.display_name
  end

  # Helper for email "from" field with company name
  def company_email_with_name
    "#{company_name} <#{company_email}>"
  end

  # Helper for admin notification email (can be different from main contact email)
  def admin_notification_email
    # You can later add a specific admin_email field to Company model if needed
    main_company.email.presence || company_email
  end
end
