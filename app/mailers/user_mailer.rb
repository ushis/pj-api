class UserMailer < ApplicationMailer

  def welcome(user)
    @mail = UserWelcomeMail.new(user)
    mail(@mail.header)
  end

  def password_reset(user)
    @mail = UserPasswordResetMail.new(user)
    mail(@mail.header)
  end
end
