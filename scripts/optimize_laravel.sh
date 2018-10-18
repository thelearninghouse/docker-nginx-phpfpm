#!/bin/sh

# optimize_laravel.sh
# ------------------
# This script is for optimizing a Laravel application that has been loaded into
# the container. If an external application like Redis will be used for caching
# it should be configured before this script if executed to ensure the cache is
# stored in the same location as the live application.

cd /app

php artisan optimize
php artisan config:cache
php artisan route:cache
