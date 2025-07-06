module ApplicationHelper
  # Company helper methods
  def main_company
    @main_company ||= Company.main
  end

  def company_email
    main_company.email.presence || 'info@mangcrinkle.com'
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
end
