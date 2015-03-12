class ApplicationMailer < ActionMailer::Base

  private

  def app_url(path)
    "#{ENV['APP_HOST']}/##{path}"
  end
end
