class OwnershipMailer < ApplicationMailer

  def create(user, ownership, creator)
    @user = user
    @ownership = ownership
    @creator = creator
    @url = ownership_url(ownership)
    mail(to: user.email_with_username, subject: subject)
  end

  private

  def subject
    if @ownership.user == @user
      "You have been appointed as owner of #{@ownership.car.name}"
    else
      "#{@creator.username} appointed #{@ownership.user.username} as owner of #{@ownership.car.name}"
    end
  end

  def ownership_url(ownership)
    app_url("/cars/#{@ownership.car.id}/owners")
  end
end
