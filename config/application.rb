require File.expand_path('../boot', __FILE__)

require 'rails'
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
#require "action_view/railtie"
#require "action_cable/engine"
#require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PjApi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Enable MailDeliveryJob
    config.action_mailer.delivery_job = 'ActionMailer::MailDeliveryJob'

    # Use sucker punch for background jobs
    config.active_job.queue_adapter = :sucker_punch

    # Run in API mode
    config.api_only = true

    # Belongs to assocations are required by default
    config.active_record.belongs_to_required_by_default = true
  end
end
