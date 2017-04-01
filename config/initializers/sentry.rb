Raven.configure do |config|
  config.dsn = ENV.fetch('SENTRY_DSN') if Rails.env.production?
  config.environments = %w(production)
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
