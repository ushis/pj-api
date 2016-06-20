class MailMetric < ApplicationMetric

  def mailer_runtime
    event.duration
  end

  def tags
    payload.slice(:mailer)
  end

  def data
    {
      'rails.mailer': mailer_runtime
    }
  end
end
