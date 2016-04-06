if !Rails.env.development? && !Rails.env.test?
  Airbrake.configure do |config|
    config.host = ENV['AIRBRAKE_HOST']
    config.project_id = ENV['AIRBRAKE_ID']
    config.project_key = ENV['AIRBRAKE_KEY']
    config.ignore_environments = [:development, :test]
  end
end
