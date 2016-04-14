class BorrowershipMailer < ApplicationMailer

  def create(user, borrowership, creator)
    @user = user
    @borrowership = borrowership
    @creator = creator
    @url = borrowership_url
    mail(to: user.email_with_username, subject: subject)
  end

  private

  def subject
    if @borrowership.user == @user
      "You have been added to #{@borrowership.car.name}"
    else
      "#{@creator.username} appointed #{@borrowership.user.username} as borrower of #{@borrowership.car.name}"
    end
  end

  def borrowership_url
    app_url("/cars/#{@borrowership.car.id}/borrowers")
  end
end
