class ApplicationMailer < ActionMailer::Base
  include ApplicationHelper
  
  default from: -> { company_email }
  layout "mailer"
end
