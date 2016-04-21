class UserPasswordResetMail < ApplicationMail

  def app_url
    super("/password/reset/#{recipient.password_reset_token}")
  end

  def subject
    'Reset your password'
  end

  def header
    {
      to: to,
      subject: subject,
      message_id: message_id
    }
  end
end
