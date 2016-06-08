Airbrake.configure do |c|
  c.host = ENV['AIRBRAKE_HOST']
  c.project_id = ENV['AIRBRAKE_ID']
  c.project_key = ENV['AIRBRAKE_KEY']
  c.root_directory = Rails.root
  c.logger = Rails.logger
  c.environment = Rails.env
  c.ignore_environments = %w(development test)
  c.blacklist_keys = [/password/i]
end
