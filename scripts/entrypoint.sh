#!/bin/sh

# entrypoint.sh
# ------------------
# This script runs as the default command for the container.

# Ensure we are running commands from the application directory
cd /app

# Export container secrets
export_secrets

# If the application is Laravel and the APP_ENV is not "local" then setup the application
# for running in a non-development mode.
if [ -f "artisan" ] && [ "$APP_ENV" != "local" ]; then
    optimize_laravel
    rm .env
fi

# Start the application environment
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
