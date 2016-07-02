# Puma config for production environments
environment 'production'

# This is a job for the supervisor
daemonize false

# We already have logs from nginx and rails
quiet

# Load app before forking
preload_app!

# Reconnect ActiveRecord after forking
on_worker_boot do
  ActiveRecord::Base.establish_connection
end
