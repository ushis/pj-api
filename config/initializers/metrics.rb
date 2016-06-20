ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |*args|
  RequestMetric.new(ActiveSupport::Notifications::Event.new(*args)).save
end

ActiveSupport::Notifications.subscribe 'deliver.action_mailer' do |*args|
  MailMetric.new(ActiveSupport::Notifications::Event.new(*args)).save
end
