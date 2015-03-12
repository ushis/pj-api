class UserMailer < ApplicationMailer

  def welcome(user)
    @user = user
    @url = app_url('/signin')
    mail(to: @user.email_with_username, subject: 'Welcome to PJ')
  end
end
