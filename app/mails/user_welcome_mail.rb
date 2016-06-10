class UserWelcomeMail < ApplicationMail

  def url
    app_url('/signin')
  end

  def subject
    'Welcome to PJ'
  end
end
