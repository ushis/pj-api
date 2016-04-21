class UserWelcomeMail < ApplicationMail

  def app_url
    super('/signin')
  end

  def subject
    'Welcome to PJ'
  end

  def header
    {
      to: to,
      subject: subject,
      message_id: message_id
    }
  end
end
