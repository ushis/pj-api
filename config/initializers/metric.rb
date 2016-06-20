ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |*args|
  begin
    Metric.new(ActiveSupport::Notifications::Event.new(*args)).save
  rescue StandardError => e
    Rails.logger.error("Could not record metric: #{e.message}")
  end
end
