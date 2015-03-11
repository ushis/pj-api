# Puma config for production environments
#
environment 'production'

# This is a job for systemd
daemonize false

# We already have logs from nginx and rails
quiet
