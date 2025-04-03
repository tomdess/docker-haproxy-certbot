#!/usr/bin/env bash

# Validate required environment variables
if [ -z "$EMAIL" ]; then
  echo "ERROR: EMAIL environment variable is required"
  exit 1
fi

# save container environment variables to use it
# in cron scripts

declare -p | grep -Ev '^declare -[[:alpha:]]*r' > /container.env

# go!
/certs.sh && supervisord -c /etc/supervisord.conf -n
