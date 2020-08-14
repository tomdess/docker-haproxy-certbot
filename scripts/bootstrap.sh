#!/usr/bin/env bash

# save container environment variables to use it
# in cron scripts

declare -p | grep -Ev '^declare -[[:alpha:]]*r' > /container.env

# go!
/certs.sh && supervisord -c /etc/supervisord.conf -n
