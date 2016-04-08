Airbrake.configure do |c|
  c.host = ENV['AIRBRAKE_HOST']
  c.project_id = ENV.fetch('AIRBRAKE_ID', true)
  c.project_key = ENV.fetch('AIRBRAKE_KEY', true)
  c.root_directory = Rails.root
  c.logger = Rails.logger
  c.environment = Rails.env
  c.ignore_environments = %w(development test)
  c.blacklist_keys = [/password/i]
end
