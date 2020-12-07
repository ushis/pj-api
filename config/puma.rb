# Puma config for production environments
environment 'production'

# We already have logs from nginx and rails
quiet

# Load app before forking
preload_app!

# Reconnect ActiveRecord after forking
on_worker_boot do
  ActiveRecord::Base.establish_connection
end
