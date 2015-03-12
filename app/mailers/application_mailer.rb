class ApplicationMailer < ActionMailer::Base

  def app_url(path)
    "#{ENV['APP_HOST']}/##{path}"
  end
end
