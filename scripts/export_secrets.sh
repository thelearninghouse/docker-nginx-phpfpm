#!/bin/sh

# export_secrets.sh
# ------------------
# This script is for exporting secrets loaded to the container instance into a .env for
# use in the PHP application. Laravel apps should run `php artisan config:cache` and then
# delete the generate .env file.

set -eo pipefail

SECRETS_DIR=/run/secrets
ENV_FILE="/app/.env"

if [ -d "$SECRETS_DIR" ]; then
    echo "We have secrets!"
    SECRETS=$(ls $SECRETS_DIR)
    touch $ENV_FILE
    for f in $SECRETS
    do
        FILENAME=$(basename $f)
        CONTENTS=$(cat $SECRETS_DIR/$f)
        echo $FILENAME=$CONTENTS >> $ENV_FILE
    done
else
    echo "No secrets."
fi
