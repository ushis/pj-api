class UserPasswordResetMail < ApplicationMail

  def url
    app_url("/password/reset/#{recipient.password_reset_token}")
  end

  def subject
    'Reset your password'
  end
end
