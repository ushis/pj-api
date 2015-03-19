class UserMailer < ApplicationMailer

  def welcome(user)
    @user = user
    @url = app_url('/signin')
    mail(to: user.email_with_username, subject: 'Welcome to PJ')
  end

  def password_reset(user)
    @user = user
    @url = app_url("/password/reset/#{user.password_reset_token}")
    mail(to: user.email_with_username, subject: 'Reset your password')
  end
end
