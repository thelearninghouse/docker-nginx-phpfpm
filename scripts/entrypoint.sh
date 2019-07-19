#!/bin/sh

# entrypoint.sh
# ------------------
# This script runs as the default command for the container.

# Ensure we are running commands from the application directory
cd /app

# If the application is Laravel and the APP_ENV is not "local" then setup the application
# for running in a non-development mode.
if [ -f "artisan" ] && [ "$APP_ENV" != "local" ]; then
    optimize_laravel
fi

# Start the application enviroment
/usr/bin/supervisord -c /etc/supervisord.conf
