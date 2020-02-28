#!/usr/bin/env bash

/certs.sh && supervisord -c /etc/supervisord.conf -n
