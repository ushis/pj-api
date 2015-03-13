class ApplicationMailer < ActionMailer::Base
  helper_method :format_datetime

  private

  def app_url(path)
    "#{ENV['APP_HOST']}/##{path}"
  end

  def format_datetime(datetime, time_zone)
    datetime.in_time_zone(time_zone).strftime('%d %b %Y, %H:%M')
  end
end
